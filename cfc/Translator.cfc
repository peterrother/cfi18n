/**
 * Undocumented component
 */
component Translator
{

	/**
	 * Undocumented variable
	 */
	variables.langFilePath = expandPath("./json");

	/**
	 * Undocumented variable
	 */
	variables.translations = {};

	/**
	 * Undocumented unknown
	 */
	variables.isCacheEnabled = true;

	/**
	 * Undocumented unknown
	 */
	variables.langCache = {};

	/**
	 * Undocumented unknown
	 */
	variables.cacheAlias = "translations";

	/**
	 * Undocumented unknown
	 */
	variables.langCacheKey = "";

	/**
	 * Undocumented unknown
	 */
	variables.langCacheRegion = "";

	/**
	 * Undocumented function
	 *
	 * @langCode
	 * @collection
	 */
	public Translator function init(
		required string langCode,
		required string collection,
		string cacheAlias = "",
		boolean resetCache = false)
	{
		local.langFilePath =
			"#variables.langFilePath#/#arguments.collection#/#arguments.langCode#.json"
		;
		if (arguments.cacheAlias.len() > 0) {
			variables.cacheAlias = arguments.cacheAlias;
		}

		variables.isCacheEnabled = isServerCacheOn();
		variables.langCacheKey = "#variables.cacheAlias#_#arguments.collection#";

		if (variables.isCacheEnabled) {
			variables.langCache = cacheGet(
				variables.langCacheKey,
				false,
				variables.langCacheRegion
			);

			if (!isNull(variables.langCache)
				&& !arguments.resetCache
				&& variables.langCache.translations.keyExists(arguments.langCode)
			) {
				variables.translations = variables.langCache.translations[arguments.langCode];
				return this;
			}
		}

		local.translationFile = fileRead(
			local.langFilePath,
			"utf-8"
		);

		variables.translations = deserializeJSON(local.translationFile);

		if (variables.isCacheEnabled) {
			if (!isNull(variables.langCache)) {
				variables.langCache.translations[arguments.langCode] = variables.translations;
			} else {
				variables.langCache = {
					"cachedOn": now(),
					"translations": {
						"#arguments.langCode#": variables.translations
					}
				};
			}

			cachePut(
				variables.langCacheKey,
				variables.langCache,
				createTimeSpan(7, 0, 0, 0),
				30,
				variables.langCacheRegion
			);
		}

		return this;
	}

	/**
	 * Undocumented function
	 *
	 * @englishPhrase
	 * @replaceMap
	 */
	public string function translate(required string englishPhrase, struct replaceMap = {})
	{
		if (!variables.translations.keyExists(arguments.englishPhrase)) {
			return arguments.englishPhrase;
		}

		local.translation = variables.translations[arguments.englishPhrase];

		if (arguments.replaceMap.len() > 0) {
			local.translation = replacePlaceholders(local.translation, arguments.replaceMap);
		}

		return local.translation;
	}

	/**
	 * Undocumented function
	 *
	 * @translation
	 * @replaceMap
	 */
	private string function replacePlaceholders(required string translation, required struct replaceMap)
	{
		local.translationOut = arguments.translation;

		local.replacements = reFindNoCase(
			"{{\s([a-zA-Z0-9_]+)\s}}",
			local.translationOut,
			1,
			true,
			"all"
		);

		if (local.replacements[1].pos[1] > 0) {
			for (local.r in local.replacements) {
				local.translationOut = local.translationOut.replace(
					local.r.match[1],
					arguments.replaceMap[local.r.match[2]]
				);
			}
		}

		return local.translationOut;
	}

	/**
	 * Undocumented function
	 *
	 */
	private boolean function isServerCacheOn()
	{
		try {
			return isArray(cacheGetProperties("object"));
		} catch (lucee.commons.io.cache.exp.CacheException noCache) {
			return false;
		}
	}

}
