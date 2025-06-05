import os
import json

def find_all_json_with_key_value(folder_path, search_key, search_value):
    """
    Searches all JSON files in a folder and returns a list of file paths
    where the JSON contains the specified key-value pair.

    Args:
        folder_path (str): Path to the folder containing JSON files.
        search_key (str): The key to look for.
        search_value: The value to match.

    Returns:
        list: List of file paths with matching key-value pair.
    """
    matching_files = []
    for filename in os.listdir(folder_path):
        if filename.endswith(".json"):
            file_path = os.path.join(folder_path, filename)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    if search_key == "id":
                        if data.get("dashboard").get(search_key) == search_value:
                            matching_files.append(file_path)
            except (json.JSONDecodeError, IOError):
                continue  # Skip unreadable or malformed files
    return matching_files

demo = find_all_json_with_key_value("backup/dashboards", "id", 1339)
print(demo)