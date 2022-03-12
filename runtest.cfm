<cfscript>
	param name="url.test" default="";

	variables.enabledTests = {
		"output_translations": {
			"filePath": "tests/output_translations.cfm"
		}
	};

	if (url.test.len() > 0
		&& variables.enabledTests.keyExists(url.test)
	) {
		include variables.enabledTests[url.test].filePath;
	}
</cfscript>
