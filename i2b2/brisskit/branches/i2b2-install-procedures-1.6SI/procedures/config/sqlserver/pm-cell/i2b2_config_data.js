{
	urlProxy: "index.php",
	urlFramework: "js-i2b2/",
	//-------------------------------------------------------------------------------------------
	// THESE ARE ALL THE DOMAINS A USER CAN LOGIN TO
	lstDomains: [
		{ domain: "${domain.name}",
		  name: "${domain.id}",
		  urlCellPM: "${pm.getservices.address.used.by.proxy}",
		  allowAnalysis: true,
		  adminOnly: true,
		  debug: false
		}
	]
	//-------------------------------------------------------------------------------------------
}
