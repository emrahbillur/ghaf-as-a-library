-- Use this script to login using tio tool.
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