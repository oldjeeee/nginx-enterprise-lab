package nginx.compliance
import rego.v1

deny contains msg if {
	input.server_tokens != "off"
	msg := "CIS 2.1 FAIL: server_tokens must be 'off' to hide version info"
}

deny contains msg if {
	not "TLSv1.3" in input.ssl_protocols
	msg := "CIS 3.1 FAIL: TLSv1.3 is mandatory for 2026 compliance"
}

deny contains msg if {
	input.locations["/stub_status"].access_control.deny_all != true
	msg := "CIS 5.1 FAIL: stub_status must be restricted to localhost only"
}

deny contains msg if {
	not startswith(input.hsts_header, "max-age=")
	msg := "CIS 6.1 FAIL: HSTS header must include max-age directive"
}
