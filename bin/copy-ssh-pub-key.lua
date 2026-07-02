-- Use this script to login and set the SSH public keys define by the user
-- via environmental variables.
-- The session is closed after the configuration is applied.
SECRET = os.getenv("SSH_SECRET")
if SECRET == nil then
    io.write("ERROR: SSH_SECRET not found in the environment.")
    return
end

GHAF_USER_PWD = os.getenv("GHAF_USER_PASSWORD")
if GHAF_USER_PWD == nil then
    io.write("ERROR: GHAF_USER_PASSWORD not found in the environment.")
    return
end

ROOT_USER_PWD = os.getenv("ROOT_USER_PASSWORD")
if ROOT_USER_PWD == nil then
    io.write("ERROR: ROOT_USER_PASSWORD not found in the environment.")
    return
end

EXPECT_TIMEOUT=1000
USER_PROMPT=":~]$"
ROOT_PROMPT="]#"

-- Login to ghaf-host
tio.expect("login:", EXPECT_TIMEOUT)
tio.write("ghaf\n")
tio.expect("Password:", EXPECT_TIMEOUT)
tio.write("ghaf\n")
tio.expect(USER_PROMPT, EXPECT_TIMEOUT)
-- Login as root user
tio.write("sudo su\n")
tio.expect("password for ghaf:", EXPECT_TIMEOUT)
tio.write("ghaf\n")
tio.expect(ROOT_PROMPT, EXPECT_TIMEOUT)

tio.write("mkdir -p /root/.ssh\n")
tio.expect(ROOT_PROMPT, EXPECT_TIMEOUT)

tio.write("echo " .. SECRET .. " >> /root/.ssh/authorized_keys\n")
tio.expect(ROOT_PROMPT, EXPECT_TIMEOUT)

-- Login to net-vm
tio.write("ssh ghaf@net-vm\n")
-- This timeout must be longer because net-vm takes time to boot
tio.expect("Password:", 10000)
tio.write("ghaf\n")
tio.expect(USER_PROMPT, EXPECT_TIMEOUT)

-- Login as root user
tio.write("sudo su\n")
tio.expect("password for ghaf:", EXPECT_TIMEOUT)
tio.write("ghaf\n")
tio.expect(ROOT_PROMPT, EXPECT_TIMEOUT)

tio.write("mkdir -p /root/.ssh\n")
tio.expect(ROOT_PROMPT, EXPECT_TIMEOUT)

tio.write("echo " .. SECRET .. " >> /root/.ssh/authorized_keys\n")
tio.expect(ROOT_PROMPT, EXPECT_TIMEOUT)

-- Go back to root user in host
tio.write("exit 0\n")
tio.expect(USER_PROMPT, EXPECT_TIMEOUT)

tio.write("exit 0\n")
tio.expect(ROOT_PROMPT, EXPECT_TIMEOUT)
