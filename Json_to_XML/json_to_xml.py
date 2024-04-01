from flask import Flask, request, jsonify
import xml.etree.ElementTree as ET

app = Flask(__name__)

def json_to_xml(json_data):
    def parse_dict(xml_parent, data):
        for key, value in data.items():
            if isinstance(value, dict):
                parse_dict(ET.SubElement(xml_parent, key), value)
            elif isinstance(value, list):
                parse_list(ET.SubElement(xml_parent, key), value)
            else:
                ET.SubElement(xml_parent, key).text = str(value)

    def parse_list(xml_parent, data):
        for item in data:
            if isinstance(item, dict):
                parse_dict(ET.SubElement(xml_parent, 'item'), item)
            else:
                ET.SubElement(xml_parent, 'item').text = str(item)

    root = ET.Element('root')
    parse_dict(root, json_data)
    return ET.tostring(root, encoding='unicode')

@app.route('/json-to-xml', methods=['POST'])
def convert_json_to_xml():
    try:
        json_data = request.get_json()
        if json_data is None:
            return jsonify({'error': 'No JSON data found in the request body'}), 400
        xml_data = json_to_xml(json_data)
        return xml_data, 200, {'Content-Type': 'application/xml'}
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
