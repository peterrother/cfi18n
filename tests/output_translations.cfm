<cfparam name="url.langCollection" default="" />
<cfparam name="url.langCode" default="" />

<cfif url.langCollection.len() eq 0>
	<cfthrow message="langCollection parameter missing" />
</cfif>

<cfif url.langCode.len() eq 0>
	<cfthrow message="langCode parameter missing" />
</cfif>

<cfscript>
	variables.testTranslator = new cfc.Translator(url.langCode, url.langCollection);
</cfscript>

<cfoutput>
	#variables.testTranslator.translate("Test string")#<br />
	#variables.testTranslator.translate("I have {{ num }} problems {{ xyz }}", {num: 99, xyz: "!"})#
</cfoutput>
