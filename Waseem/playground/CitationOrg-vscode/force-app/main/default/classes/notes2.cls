(Header:[name=Return-Path, 
value=salesforceinbound@citation.co.uk], 
Header:[name=Authentication-Results, 
value=mx1-lo2-sp1.mta.salesforce.com 
x-tls.subject="/C=GB/L=London/O=Mimecast 
Services Limited/CN=*.mimecast.com"; 
auth=pass (cipher=ECDHE-RSA-AES256-GCM-SHA384)], 
Header:[name=Authentication-Results, 
value=apex.salesforce.com; dkim=pass 
header.d=citation.co.uk], Header:[name=Received, 
value=from [185.58.85.166] ([185.58.85.166:22103] 
helo=eu-smtp-delivery-166.mimecast.com)	by 
mx1-lo2-sp1.mta.salesforce.com (envelope-from <salesforceinbound@citation.co.uk>)	
(ecelerity 4.4.0.19839 r(msys-ecelerity:tags/4.4.0.0^0)) with ESMTPS 
(cipher=ECDHE-RSA-AES256-GCM-SHA384	subject="/C=GB/L=London/O=Mimecast 
Services Limited/CN=*.mimecast.com") 	id 94/88-56300-96802E36; Tue, 07 Feb 2023 08:14:33 +0000], 
Header:[name=DKIM-Signature, value=v=1; a=rsa-sha256; c=relaxed/relaxed; d=citation.co.uk;	s=mimecast20160715; t=1675757673;	
h=from:from:reply-to:subject:subject:date:date:message-id:message-id:	 
to:to:cc:mime-version:mime-version:content-type:content-type:  resent-from;	
bh=wN38qAM3jAusLiwh2upnIgQKpfrkCrFMnd9mM2HLivY=;	b=ozeXm5g8ErzUrKQd4yxNagp+8OzAlZDOYD99g19WOC1UFRW5Y2MVEW8WkihNOiak4qIEHS	
7Em4ace9A9oIZ0X0ByegNOUgip19/OGT1wYktKIFdOclfH85so4d2qiSNoS21J5qHHdecA	kG4aZbOOGsG8cL52IXKp8Ym3IC+8N3I=], 
Header:[name=Received, value=from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01lp2055.outbound.protection.outlook.com [104.47.1.55]) 
by relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id uk-mta-268-Hap1O1dXPB6FYse6YArMkg-1; Tue, 07 Feb 2023 08:14:31 +0000], 
Header:[name=X-MC-Unique, value=Hap1O1dXPB6FYse6YArMkg-1], Header:[name=Resent-From, value=<salesforceinbound@citation.co.uk>], 
Header:[name=Received, value=from FR0P281CA0107.DEUP281.PROD.OUTLOOK.COM (2603:10a6:d10:a8::20) by CWLP265MB6181.GBRP265.PROD.OUTLOOK.COM (2603:10a6:400:180::12) with Microsoft SMTP Server 
(version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.6064.34; Tue, 7 Feb 2023 08:14:30 +0000], Header:[name=Received, value=from VI1EUR02FT055.eop-EUR02.prod.protection.outlook.com (2603:10a6:d10:a8:cafe::4c) by 
FR0P281CA0107.outlook.office365.com (2603:10a6:d10:a8::20) with Microsoft SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) 
id 15.20.6086.15 via Frontend Transport; Tue, 7 Feb 2023 08:14:30 +0000], ...)