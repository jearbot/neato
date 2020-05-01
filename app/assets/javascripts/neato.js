<script src="//ajax.googleapis.com/ajax/libs/jquery/2.2.0/jquery.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/crypto-js/3.1.2/rollups/hmac-sha256.js"></script>
<script src="../lib/neato-0.9.0.min.js"></script>

var user = new Neato.User();
user.login({
  clientId:    "your_app_client_id",
  scopes:      "control_robots+email+maps",
  redirectUrl: "your_redirect_uri"
});