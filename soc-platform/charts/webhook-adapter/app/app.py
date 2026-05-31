import os
import logging
from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

THEHIVE_URL = os.environ.get('THEHIVE_URL', 'http://thehive:9000')
THEHIVE_API_KEY = os.environ.get('THEHIVE_API_KEY')

if not THEHIVE_API_KEY:
    logger.warning("THEHIVE_API_KEY is not set. API calls to TheHive will fail.")

@app.route('/webhook', methods=['POST'])
def handle_wazuh_alert():
    try:
        data = request.json
        if not data:
            return jsonify({"error": "No JSON payload provided"}), 400

        # Extract Wazuh alert data
        rule = data.get('rule', {})
        rule_level = rule.get('level', 0)
        rule_description = rule.get('description', 'Unknown Wazuh Alert')
        agent = data.get('agent', {})
        agent_name = agent.get('name', 'Unknown Agent')
        
        # Map Wazuh rule level to TheHive severity (1-4)
        # 1-4 = 1 (Low), 5-7 = 2 (Medium), 8-11 = 3 (High), 12-15 = 4 (Critical)
        severity = 1
        if rule_level >= 12:
            severity = 4
        elif rule_level >= 8:
            severity = 3
        elif rule_level >= 5:
            severity = 2

        # Format the description
        full_description = f"**Agent:** {agent_name}\n"
        full_description += f"**Rule Level:** {rule_level}\n"
        full_description += f"**Location:** {data.get('location', 'Unknown')}\n"
        full_description += f"\n**Full Log:**\n```\n{data.get('full_log', '')}\n```"

        # Create TheHive alert payload (v4/v5 API)
        thehive_alert = {
            "title": f"Wazuh: {rule_description}",
            "description": full_description,
            "severity": severity,
            "type": "wazuh_alert",
            "source": "wazuh",
            "sourceRef": data.get('id', 'unknown_id'),
            "tags": ["wazuh", f"level_{rule_level}", f"agent_{agent_name}"]
        }

        # Send to TheHive
        headers = {
            'Authorization': f'Bearer {THEHIVE_API_KEY}',
            'Content-Type': 'application/json'
        }
        
        response = requests.post(
            f"{THEHIVE_URL}/api/alert",
            headers=headers,
            json=thehive_alert,
            verify=False  # Useful in lab, ensure true in production if SSL
        )

        if response.status_code == 201:
            logger.info(f"Successfully created TheHive alert for Wazuh rule {rule.get('id')}")
            return jsonify({"status": "success", "message": "Alert created"}), 201
        else:
            logger.error(f"Failed to create TheHive alert. Status: {response.status_code}, Body: {response.text}")
            return jsonify({"status": "error", "message": "Failed to create alert in TheHive", "details": response.text}), response.status_code

    except Exception as e:
        logger.error(f"Error processing webhook: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
