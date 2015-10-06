<cfcomponent output="false" persistent="false">

	<cfset variables.assets = {} />

	<cffunction name="init" output="false" access="public" returntype="any">
		<cfargument name="manifest" type="string" required="false" />

		<cfif structKeyExists(arguments, "manifest")>
			<cfset loadManifest(arguments.manifest) />
		</cfif>

		<cfreturn this />
	</cffunction>


	<cffunction name="loadManifest" output="false" access="public" returntype="boolean" hint="Open JSON manifest file and update asset cache">
		<cfargument name="manifest" type="string" required="true" />

		<cfif fileExists(arguments.manifest)>
			<cfset local.json = fileRead(arguments.manifest, "utf-8") />
			<cfif isJson(local.json)>
				<cflock name="asset_cache_manifest" type="exclusive" timeout="5" throwontimeout="true">
					<cfset variables.assets = deserializeJson(local.json) />
					<cfreturn true />
				</cflock>
			</cfif>
		<cfelse>
			<cfthrow message="Asset manifest file does not exist" />
		</cfif>

		<cfreturn false />
	</cffunction>


	<cffunction name="getAsset" output="false" access="public" returntype="any" hint="Return the cache-busted CDN path to the file">
		<cfargument name="asset" type="string" required="true" />

		<cflock name="asset_cache_manifest" type="readonly" timeout="5">
			<cfif structKeyExists(variables.assets, arguments.asset)>
				<!--- when found, return the transformed asset name --->
				<cfreturn variables.assets[arguments.asset] />
			<cfelse>
				<cfthrow message="Asset not found in manifest" detail="#arguments.asset#" />
			</cfif>
		</cflock>
	</cffunction>

</cfcomponent>
