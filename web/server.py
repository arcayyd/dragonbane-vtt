import sys
import os
import json
from http.server import SimpleHTTPRequestHandler, HTTPServer

# Memory database for rooms
ROOMS = {}

def save_room(room_code, room_state):
    try:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        # Find project root (up 2 levels if running in build/web, or up 1 if in web/)
        project_root = os.path.abspath(os.path.join(script_dir, '..', '..'))
        if not os.path.exists(os.path.join(project_root, 'pubspec.yaml')):
            project_root = os.path.abspath(os.path.join(script_dir, '..'))
            
        sessions_dir = os.path.join(project_root, 'sessions')
        if not os.path.exists(sessions_dir):
            os.makedirs(sessions_dir)
            
        file_path = os.path.join(sessions_dir, f'{room_code}.json')
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(room_state, f, indent=2, ensure_ascii=False)
    except Exception as e:
        print(f"Error saving session file: {e}")

def load_room(room_code):
    if room_code in ROOMS:
        return ROOMS[room_code]
        
    try:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.abspath(os.path.join(script_dir, '..', '..'))
        if not os.path.exists(os.path.join(project_root, 'pubspec.yaml')):
            project_root = os.path.abspath(os.path.join(script_dir, '..'))
            
        file_path = os.path.join(project_root, 'sessions', f'{room_code}.json')
        if os.path.exists(file_path):
            with open(file_path, 'r', encoding='utf-8') as f:
                room_state = json.load(f)
                ROOMS[room_code] = room_state
                return room_state
    except Exception as e:
        print(f"Error loading session file: {e}")
    return None

class VttSyncRequestHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        # Allow CORS for local testing from other ports if necessary
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200, "OK")
        self.end_headers()

    def do_GET(self):
        # Intercept GET /api/room/<room_code>
        if self.path.startswith('/api/room/'):
            room_code = self.path.split('/')[-1].upper()
            room_state = load_room(room_code)
            if room_state:
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps(room_state).encode('utf-8'))
            else:
                self.send_response(404)
                self.end_headers()
                self.wfile.write(b"Room not found")
            return
        
        # Default behavior: serve static files
        super().do_GET()

    def do_POST(self):
        # Intercept POST /api/room/<room_code>
        if self.path.startswith('/api/room/'):
            room_code = self.path.split('/')[-1].upper()
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            try:
                room_state = json.loads(post_data.decode('utf-8'))
                ROOMS[room_code] = room_state
                save_room(room_code, room_state)
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(b'{"status":"ok"}')
            except Exception as e:
                self.send_response(400)
                self.end_headers()
                self.wfile.write(f"Error parsing JSON: {str(e)}".encode('utf-8'))
            return
        
        self.send_response(404)
        self.end_headers()

def run(port=8080):
    # Make sure we serve files from the directory of this script (build/web)
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    server_address = ('', port)
    httpd = HTTPServer(server_address, VttSyncRequestHandler)
    print(f"Starting Dragonbane VTT Relay Server on port {port}...")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    print("Stopping server.")

if __name__ == '__main__':
    port = 8080
    if len(sys.argv) > 1:
        port = int(sys.argv[1])
    run(port)
