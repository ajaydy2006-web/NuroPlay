import http.server
import socketserver
import os
import sys
import json
import time

PORT = 8080
DIRECTORY = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build", "web")
ROOMS = {}

class NuroPlayHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_GET(self):
        if self.path == "/" or self.path == "":
            self.send_response(302)
            self.send_header("Location", "/NuroPlay/")
            self.end_headers()
            return

        if self.path.startswith("/api/rooms/"):
            room_id = self.path.split("/api/rooms/")[1].strip("/").upper()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            room = ROOMS.get(room_id)
            if room:
                if room.get("status") == 0 and (time.time() - room.get("created_at_sec", 0)) > room.get("timeoutSeconds", 60):
                    room["status"] = 4  # expired
                self.wfile.write(json.dumps(room).encode("utf-8"))
            else:
                self.wfile.write(json.dumps({"error": "not_found"}).encode("utf-8"))
            return

        return super().do_GET()

    def do_POST(self):
        if self.path.startswith("/api/rooms"):
            content_length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(content_length).decode("utf-8")
            data = json.loads(body) if body else {}

            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()

            if self.path == "/api/rooms/create":
                room_id = data.get("roomId", "").upper()
                data["created_at_sec"] = time.time()
                ROOMS[room_id] = data
                self.wfile.write(json.dumps({"success": True, "room": data}).encode("utf-8"))
                return
            elif "/join" in self.path:
                room_id = self.path.split("/api/rooms/")[1].split("/join")[0].strip("/").upper()
                room = ROOMS.get(room_id)
                if room:
                    room["guestName"] = data.get("guestName")
                    room["guestAvatar"] = data.get("guestAvatar")
                    room["status"] = 1  # joined
                    self.wfile.write(json.dumps({"success": True, "room": room}).encode("utf-8"))
                else:
                    self.wfile.write(json.dumps({"success": False, "error": "not_found"}).encode("utf-8"))
                return
            elif "/close" in self.path:
                room_id = self.path.split("/api/rooms/")[1].split("/close")[0].strip("/").upper()
                if room_id in ROOMS:
                    ROOMS[room_id]["status"] = 3  # closed
                self.wfile.write(json.dumps({"success": True}).encode("utf-8"))
                return

        self.send_response(404)
        self.end_headers()

    def translate_path(self, path):
        if path.startswith("/NuroPlay/"):
            path = path[len("/NuroPlay"):]
        elif path == "/NuroPlay":
            path = "/"
        return super().translate_path(path)

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        super().end_headers()

if __name__ == "__main__":
    os.chdir(DIRECTORY)
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), NuroPlayHandler) as httpd:
        print(f"Server ready at http://localhost:{PORT}/NuroPlay/")
        sys.stdout.flush()
        httpd.serve_forever()
