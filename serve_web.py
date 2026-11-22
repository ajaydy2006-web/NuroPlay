import http.server
import socketserver
import os
import sys

PORT = 8080
DIRECTORY = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build", "web")

class NuroPlayHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_GET(self):
        if self.path == "/" or self.path == "":
            self.send_response(302)
            self.send_header("Location", "/NuroPlay/")
            self.end_headers()
            return
        return super().do_GET()

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
