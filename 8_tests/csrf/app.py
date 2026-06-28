from flask import Flask, session, request, redirect, url_for, render_template_string

app = Flask(__name__)
app.secret_key = "dev-secret-key"  # required for sessions

# mock user storage
USER_DB = {
    "alice": {
        "password": "password123",
        "email": "alice@example.com"
    }
}

# login page
LOGIN_PAGE = """
<form method="POST">
  <input name="username" placeholder="username">
  <input name="password" type="password" placeholder="password">
  <button type="submit">Login</button>
</form>
<p>{{ error }}</p>
"""

# settings page
SETTINGS_PAGE = """
<h2>Account settings</h2>
<p>Logged in as: {{ user }}</p>

<form method="POST" action="/settings">
  <input name="email" value="{{ email }}" />
  <button type="submit">Update email</button>
</form>

<a href="/logout">Logout</a>
"""

@app.route("/", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        u = request.form.get("username")
        p = request.form.get("password")

        if u in USER_DB and USER_DB[u]["password"] == p:
            session["user"] = u
            return redirect(url_for("settings"))

        return render_template_string(LOGIN_PAGE, error="Invalid credentials")

    return render_template_string(LOGIN_PAGE, error="")

@app.route("/settings", methods=["GET", "POST"])
def settings():
    print(session)
    if "user" not in session:
        return redirect(url_for("login"))

    user = session["user"]

    if request.method == "POST":
        new_email = request.form.get("email")
        USER_DB[user]["email"] = new_email
        return redirect(url_for("settings"))

    return render_template_string(
        SETTINGS_PAGE,
        user=user,
        email=USER_DB[user]["email"]
    )

@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))

if __name__ == "__main__":
    app.run(debug=True)
