import os, sys
import json

def read_solver_json_info(json_path):
    """Just load the JSON file to a dict"""
    with open(json_path) as f: info = json.load(f)
    return info
