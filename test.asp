<%
option explicit

dim duo, ikey, wrong_ikey, skey, akey
dim user, invalid_user, expired_user, future_user
dim invalid_response, expired_response, future_response
dim request_sig, duo_sig, valid_app_sig, invalid_app_sig, wrong_params_response, wrong_params_app
dim parts

ikey = "DIXXXXXXXXXXXXXXXXXX"
wrong_ikey = "DIXXXXXXXXXXXXXXXXXY"
skey = "deadbeefdeadbeefdeadbeefdeadbeefdeadbeef"
akey = "useacustomerprovidedapplicationsecretkey"

user = "testuser"

invalid_response = "AUTH|INVALID|SIG"
expired_response = "AUTH|dGVzdHVzZXJ8RElYWFhYWFhYWFhYWFhYWFhYWFh8MTMwMDE1Nzg3NA==|cb8f4d60ec7c261394cd5ee5a17e46ca7440d702"
future_response = "AUTH|dGVzdHVzZXJ8RElYWFhYWFhYWFhYWFhYWFhYWFh8MTYxNTcyNzI0Mw==|d20ad0d1e62d84b00a3e74ec201a5917e77b6aef"
wrong_params_response = "AUTH|dGVzdHVzZXJ8RElYWFhYWFhYWFhYWFhYWFhYWFh8MTYxNTcyNzI0M3xpbnZhbGlkZXh0cmFkYXRh|6cdbec0fbfa0d3f335c76b0786a4a18eac6cdca7"
wrong_params_app = "APP|dGVzdHVzZXJ8RElYWFhYWFhYWFhYWFhYWFhYWFh8MTYxNTcyNzI0M3xpbnZhbGlkZXh0cmFkYXRh|7c2065ea122d028b03ef0295a4b4c5521823b9b5"


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' tests for sign_request()
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

set duo = GetObject("script:"&Server.MapPath("duo.wsc"))
request_sig = duo.sign_request(ikey, skey, akey, user)
if request_sig = "" then
    Response.Write "did not generate signed request."
end if
set duo = Nothing

set duo = GetObject("script:"&Server.MapPath("duo.wsc"))
request_sig = duo.sign_request(ikey, skey, akey, "")
if request_sig <> duo.ERR_USER then
    Response.Write "did not catch username error."
end if
set duo = Nothing

set duo = GetObject("script:"&Server.MapPath("duo.wsc"))
request_sig = duo.sign_request(ikey, skey, akey, "in|valid")
if request_sig <> duo.ERR_USER then
    Response.Write "did not catch username error."
end if
set duo = Nothing

set duo = GetObject("script:"&Server.MapPath("duo.wsc"))
request_sig = duo.sign_request("invalid", skey, akey, user)
if request_sig <> duo.ERR_IKEY then
    Response.Write "did not catch ikey error."
end if
set duo = Nothing

set duo = GetObject("script:"&Server.MapPath("duo.wsc"))
request_sig = duo.sign_request(ikey, "invalid", akey, user)
if request_sig <> duo.ERR_SKEY then
    Response.Write "did not catch skey error."
end if
set duo = Nothing

set duo = GetObject("script:"&Server.MapPath("duo.wsc"))
request_sig = duo.sign_request(ikey, skey, "invalid", user)
if request_sig <> duo.ERR_AKEY then
    Response.Write "did not catch akey error."
end if
set duo = Nothing

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' tests for verify_response()
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

set duo = GetObject("script:"&Server.MapPath("duo.wsc"))
request_sig = duo.sign_request(ikey, skey, akey, user)
if request_sig = "" then
    Response.Write "did not generate signed request."
end if
set duo = Nothing

parts = Split(request_sig, ":")
duo_sig = parts(0)
valid_app_sig = parts(1)

set duo = GetObject("script:"&Server.MapPath("duo.wsc"))
request_sig = duo.sign_request(ikey, skey, "invalidinvalidinvalidinvalidinvalidinvalid", user)
if request_sig = "" then
    Response.Write "did not generate signed request."
end if
set duo = Nothing

parts = Split(request_sig, ":")
duo_sig = parts(0)
invalid_app_sig = parts(1)

set duo = GetObject("script:"&Server.MapPath("duo.wsc"))
invalid_user = duo.verify_response(ikey, skey, akey, invalid_response + ":" + valid_app_sig)
if not isNull(invalid_user) then 
    Response.Write "failed invalid user verify test."
end if
set duo = Nothing

set duo = GetObject("script:"&Server.MapPath("duo.wsc"))
expired_user = duo.verify_response(ikey, skey, akey, expired_response + ":" + valid_app_sig)
if not isNull(expired_user) then 
    Response.Write "failed expired user verify test."
end if
set duo = Nothing

set duo = GetObject("script:"&Server.MapPath("duo.wsc"))
future_user = Duo.verify_response(ikey, skey, akey, future_response + ":" + invalid_app_sig)
if not isNull(future_user) then
    Response.Write "failed future user invalid app sig test."
end if
set duo = Nothing

set duo = GetObject("script:"&Server.MapPath("duo.wsc"))
future_user = Duo.verify_response(ikey, skey, akey, future_response + ":" + valid_app_sig)
if future_user <> user then
    Response.Write "failed future user valid app sig test."
end if
set duo = Nothing

set duo = GetObject("script:"&Server.MapPath("duo.wsc"))
future_user = Duo.verify_response(ikey, skey, akey, wrong_params_response + ":" + valid_app_sig)
if not isNull(future_user) then
    Response.Write "failed future user bad response format test."
end if
set duo = Nothing

set duo = GetObject("script:"&Server.MapPath("duo.wsc"))
future_user = Duo.verify_response(ikey, skey, akey, future_response + ":" + wrong_params_app)
if not isNull(future_user) then
    Response.Write "failed future user bad app sig format test."
end if
set duo = Nothing

set duo = GetObject("script:"&Server.MapPath("duo.wsc"))
future_user = Duo.verify_response(wrong_ikey, skey, akey, future_response + ":" + valid_app_sig)
if not isNull(future_user) then
    Response.Write "failed future user wrong ikey test."
end if
set duo = Nothing

Response.Write "end of tests."

%>
