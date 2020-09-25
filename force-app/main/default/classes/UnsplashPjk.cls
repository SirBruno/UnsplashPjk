public with sharing class UnsplashPjk {

	public String imageId { get; set; }
	public String imageURL { get; set; }
	public static Cookie unsplashApiBearer = ApexPages.currentPage().getCookies().get('unsplashApiBearer');
	public static String username { get; set; }
	public static String profileImg { get; set; }
	public static String loggedInUser { get; set; }
	public static String authEndpoint = 'https://unsplash.com/oauth/token';
	public static String redirect_uri = 'https://bruno-pereira-dev-ed--c.visualforce.com/apex/UnsplashPjk';
	public static String client_id = 'M2jzfHFiRRslZvyg6-e5T8jPDWDFT8z3SdZZHd1aJyA';
	public static String client_secret = 'eTMWlaYPGD-8Z7nKpWokdFgRfon-_bx2aNhhumGPlPw';
	public static String authCode = Apexpages.currentPage().getParameters().get('code');

	public PageReference addToFavorites() {
		Account acc = [SELECT Id FROM Account WHERE UnsplashUsername__c =: loggedInUser == null ? 'sirbruninn' : loggedInUser LIMIT 1];
		Database.SaveResult sr = Database.insert(New LikedImages__c(imageId__c=imageId, imageURL__c=imageURL, Account__c=acc.Id), false);

		if (sr.isSuccess()) {
			System.debug('SUCCESS: ' + sr.getId());
		}
		else {
			for(Database.Error err : sr.getErrors()) {
				System.debug('ERROR: ' + err.getStatusCode() + ': ' + err.getMessage());
			}
		}

		PageReference pr = Page.AddedToFavorites;
		pr.getParameters().put('postId', imageId);
		pr.setRedirect(true);
		return pr;
	}

	public PageReference removeFromFavorites() {
		Account acc = [SELECT Id FROM Account WHERE UnsplashUsername__c =: loggedInUser == null ? 'sirbruninn' : loggedInUser LIMIT 1];
		Database.DeleteResult sr = Database.delete((LikedImages__c)[SELECT Id FROM LikedImages__c WHERE imageId__c=:imageId LIMIT 1], false);

		if (sr.isSuccess()) {
			System.debug('SUCCESS: ' + sr.getId());
		}
		else {
			for(Database.Error err : sr.getErrors()) {
				System.debug('ERROR: ' + err.getStatusCode() + ': ' + err.getMessage());
			}
		}

		PageReference pr = Page.AddedToFavorites;
		pr.getParameters().put('postId', imageId);
		pr.setRedirect(true);
		return pr;
	}

	public static Map<String, Object> getLikedImages(HttpResponse response) {
		Map<String, Object> dataMap = new Map<String, Object>();
		List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
	
		Set<String> imgIds = new Set<String>();
		for (LikedImages__c l : [SELECT imageId__c FROM LikedImages__c WHERE Account__r.unsplashUsername__c='sirbruninn']) {
			imgIds.add((String)l.imageId__c);
		}

		Integer i = 0;
		for (Object r : results) {
			Map<String, Object> data = (Map<String, Object>)r;
			Map<String, Object> dataImgUrls = (Map<String, Object>)data.get('urls');
			String isLiked = imgIds.contains((String)data.get('id')) ? 'Liked' : 'Not Liked';
			String reqRes = '{"id": "' + (String)data.get('id') + '", "isLiked": "' + (String)isLiked + '", "imgUrl": "'+(String)dataImgUrls.get('regular')+'"}';
			Object postBody = JSON.deserializeUntyped(reqRes.replaceAll('\n', '').replaceAll('\r', ''));
			dataMap.put(String.valueOf(i), postBody);
			i++;
		}

		return dataMap;
	}

	public static Map<String, Object> getData() {

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		HttpResponse response;

		if (unsplashApiBearer != null) {
			request.setEndpoint('https://api.unsplash.com/me');
			request.setMethod('GET');
			request.setHeader('Authorization', 'Bearer ' + unsplashApiBearer.getValue());
			response = http.send(request);

			if (response.getStatusCode() != 200){
				System.debug('ERROR: ' + response.getStatusCode()+' ' + response.getStatus());
			} else {
				Map<String, Object> results = new Map<String, Object>();
				results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
				Map<String, Object> profileImgLinks = (Map<String, Object>)results.get('profile_image');
				loggedInUser = (String)results.get('username');
				username = (String)results.get('name');
				profileImg = (String)profileImgLinks.get('large');
			}
		}

		if ((Apexpages.currentPage().getParameters().get('code') != null) && (username == null)){
			request.setEndpoint(''+ authEndpoint
														+ '?client_id=' + client_id
														+ '&client_secret=' + client_secret
														+ '&redirect_uri=' + redirect_uri
														+ '&code=' + authCode
														+ '&grant_type=authorization_code');
			request.setMethod('POST');
			response = http.send(request);

			if (response.getStatusCode() == 200) {
				Map<Object, Object> dataMap = new Map<Object, Object>();
				Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

				Cookie bearerToken = new Cookie('unsplashApiBearer', (String)results.get('access_token'), null,  - 1, true);
				ApexPages.currentPage().setCookies(new Cookie[]{bearerToken});

				request.setEndpoint('https://api.unsplash.com/users/'+loggedInUser+'/likes');
				request.setMethod('GET');
				request.setHeader('Authorization', 'Bearer ' + bearerToken.getValue());
				response = http.send(request);

				if (response.getStatusCode() == 200) {
					return getLikedImages(response);
				} else {
					System.debug('ERROR: ' + response.getStatusCode() + ' ' + response.getStatus());
				}
			}
		}

		if ((unsplashApiBearer != null) && (loggedInUser != null)) {
			request.setEndpoint('https://api.unsplash.com/users/'+loggedInUser+'/likes');
			request.setMethod('GET');
			request.setHeader('Authorization', 'Bearer ' + unsplashApiBearer.getValue());
			response = http.send(request);

			if (response.getStatusCode() == 200) {
				return getLikedImages(response);
			} else {
				System.debug('ERROR: ' + response.getStatusCode() + ' ' + response.getStatus());
				return null;
			}
		} else {
					Map<String, Object> dataMap = new Map<String, Object>();
					for (Integer i = 0; i < 10; i++) {

						String reqRes = '{"id": "' + String.valueOf(i) + '", "isLiked": "Liked", "imgUrl": "https://dummyimage.com/1920x1080/000/ffffff.png&text=+++++++unsplashpjk+++++++"}';
						Object postBody = JSON.deserializeUntyped(reqRes.replaceAll('\n', '').replaceAll('\r', ''));

						dataMap.put(String.valueOf(i), postBody);
					}

					return dataMap;
		}
	}
}