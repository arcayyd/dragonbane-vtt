import http.server
import socketserver
import os
import json

ROOMS = {}

class ThreadedHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = True

PORT = 8080
DIRECTORY = os.path.abspath(os.path.join(os.path.dirname(__file__), "build", "web"))

class VttSyncHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_GET(self):
        if self.path.startswith('/api/room/'):
            room_code = self.path.replace('/api/room/', '').strip('/')
            if not room_code or room_code == 'null' or room_code not in ROOMS:
                self.send_response(404)
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                return
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(ROOMS[room_code]).encode('utf-8'))
            return
        super().do_GET()

    def do_POST(self):
        if self.path.startswith('/api/room/'):
            room_code = self.path.replace('/api/room/', '').strip('/')
            if not room_code or room_code == 'null':
                self.send_response(400)
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                return
            content_length = int(self.headers.get('Content-Length', 0))
            post_body = self.rfile.read(content_length)
            try:
                room_json = json.loads(post_body.decode('utf-8'))
                if room_json and isinstance(room_json, dict) and room_json.get('roomCode'):
                    ROOMS[room_code] = room_json
                    self.send_response(200)
                    self.send_header('Content-Type', 'application/json')
                    self.send_header('Access-Control-Allow-Origin', '*')
                    self.end_headers()
                    self.wfile.write(b'{"status":"ok"}')
                else:
                    self.send_response(400)
                    self.end_headers()
            except Exception:
                self.send_response(400)
                self.end_headers()
            return
        super().do_POST()

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

if __name__ == '__main__':
    with ThreadedHTTPServer(('0.0.0.0', PORT), VttSyncHandler) as httpd:
        print(f"Server VTT Sync Real-Time attivo su http://0.0.0.0:{PORT}")
        httpd.serve_forever()
