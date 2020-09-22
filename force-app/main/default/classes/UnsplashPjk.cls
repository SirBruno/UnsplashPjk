public with sharing class UnsplashPjk{
	public UnsplashPjk(){
		getUserInfo();
		// setBearerTokenCookie();
	}

	public static Cookie unsplashApiBearer = ApexPages.currentPage().getCookies().get('unsplashApiBearer');
	public static String username { get; set; }
	public static String profileImg { get; set; }
	public static String loggedInUser { get; set; }
	public static String authEndpoint = 'https://unsplash.com/oauth/token';
	public static String redirect_uri = 'https://bruno-pereira-dev-ed--c.visualforce.com/apex/UnsplashPjk';
	public static String client_id = 'M2jzfHFiRRslZvyg6-e5T8jPDWDFT8z3SdZZHd1aJyA';
	public static String client_secret = 'eTMWlaYPGD-8Z7nKpWokdFgRfon-_bx2aNhhumGPlPw';
	public static String authCode = Apexpages.currentPage().getParameters().get('code');
	public static Map<String, Object> userLikedImages { get; set; }

	// public static void getUserInfo(){
	// 	if (unsplashApiBearer != null){
	// 		// System.debug('getUserInfo');
	// 		Http http = new Http();
	// 		HttpRequest request = new HttpRequest();
	// 		request.setEndpoint('https://api.unsplash.com/me');
	// 		request.setMethod('GET');
	// 		request.setHeader('Authorization', 'Bearer ' + unsplashApiBearer.getValue());
	// 		HttpResponse response = http.send(request);
	// 		response = http.send(request);

	// 		if (response.getStatusCode() != 200){
	// 			System.debug('ERROR: ' + response.getStatusCode()+' ' + response.getStatus());
	// 		} else {
	// 			Map<String, Object> results = new Map<String, Object>();
	// 			results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
	// 			Map<String, Object> profileImgLinks = (Map<String, Object>)results.get('profile_image');
	// 			loggedInUser = (String)results.get('username');
	// 			username = (String)results.get('name');
	// 			profileImg = (String)profileImgLinks.get('large');
	// 			// userLikedImages = userLikedImagesData;

	// 			request.setEndpoint('https://api.unsplash.com/users/'+loggedInUser+'/likes');
	// 			request.setMethod('GET');
	// 			request.setHeader('Authorization', 'Bearer ' + unsplashApiBearer.getValue());
	// 			response = http.send(request);

	// 			if (response.getStatusCode() == 200) {

	// 				Map<String, Object> dataMap = new Map<String, Object>();
	// 				List<Object> reqResults = (List<Object>)JSON.deserializeUntyped(response.getBody());
				
	// 				Integer i = 0;
	// 				for (Object r : reqResults) {
	// 					Map<String, Object> data = (Map<String, Object>)r;
	// 					Map<String, Object> dataImgUrls = (Map<String, Object>)data.get('urls');

	// 					String reqRes = '{"id": "' + (String)data.get('id') + '", "imgUrl": "'+(String)dataImgUrls.get('regular')+'"}';
	// 					Object postBody = JSON.deserializeUntyped(reqRes.replaceAll('\n', '').replaceAll('\r', ''));

	// 					dataMap.put(String.valueOf(i), postBody);
	// 					i++;
	// 				}

	// 				userLikedImages = dataMap;

	// 			} else {
	// 				System.debug('ERROR: ' + response.getStatusCode() + ' ' + response.getStatus());
	// 			}
	// 		}
	// 	}
	// }

	public static void getUserInfo(){
		if (unsplashApiBearer != null) {
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint('https://api.unsplash.com/me');
			request.setMethod('GET');
			request.setHeader('Authorization', 'Bearer ' + unsplashApiBearer.getValue());
			HttpResponse response = http.send(request);
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
	}

	public static void setBearerTokenCookie(){
		if ((Apexpages.currentPage().getParameters().get('code') != null) && (username == null)){
			// System.debug('setBearerTokenCookie');
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(''+ authEndpoint
														+ '?client_id=' + client_id
														+ '&client_secret=' + client_secret
														+ '&redirect_uri=' + redirect_uri
														+ '&code=' + authCode
														+ '&grant_type=authorization_code');
			request.setMethod('POST');
			HttpResponse response = http.send(request);

			if (response.getStatusCode() == 200){
				Map<Object, Object> dataMap = new Map<Object, Object>();
				Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

				Cookie bearerToken = new Cookie('unsplashApiBearer', (String)results.get('access_token'), null,  - 1, true);
				ApexPages.currentPage().setCookies(new Cookie[]{bearerToken});

				request.setEndpoint('https://api.unsplash.com/me');
				request.setMethod('GET');
				request.setHeader('Authorization', 'Bearer ' + (String)results.get('access_token'));
				response = http.send(request);

				if (response.getStatusCode() != 200){
					System.debug('ERROR: ' + response.getStatusCode()+' ' + response.getStatus());
				} else {
					results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
					Map<String, Object> profileImgLinks = (Map<String, Object>)results.get('profile_image');
					loggedInUser = (String)results.get('username');
					username = (String)results.get('name');
					profileImg = (String)profileImgLinks.get('large');
					// userLikedImages = userLikedImagesData;
					System.debug(bearerToken);
					request.setEndpoint('https://api.unsplash.com/users/'+loggedInUser+'/likes');
					request.setMethod('GET');
					request.setHeader('Authorization', 'Bearer ' + bearerToken.getValue());
					response = http.send(request);

					if (response.getStatusCode() == 200) {

						Map<String, Object> dataMapNew = new Map<String, Object>();
						List<Object> resultsNew = (List<Object>)JSON.deserializeUntyped(response.getBody());
					
						Integer i = 0;
						for (Object r : resultsNew) {
							Map<String, Object> data = (Map<String, Object>)r;
							Map<String, Object> dataImgUrls = (Map<String, Object>)data.get('urls');

							String reqRes = '{"id": "' + (String)data.get('id') + '", "imgUrl": "'+(String)dataImgUrls.get('regular')+'"}';
							Object postBody = JSON.deserializeUntyped(reqRes.replaceAll('\n', '').replaceAll('\r', ''));

							dataMapNew.put(String.valueOf(i), postBody);
							i++;
						}

						userLikedImages = dataMapNew;

					} else {
						System.debug('ERROR: ' + response.getStatusCode() + ' ' + response.getStatus());
					}
				}
			}
		}
	}

	public String imageId { get; set; }
	public String imageURL { get; set; }

	public PageReference addToFavorites() {
		Account acc = [SELECT Id FROM Account WHERE UnsplashUsername__c =: loggedInUser == null ? 'sirbruninn' : loggedInUser LIMIT 1];
		LikedImages__c likedImages = New LikedImages__c(imageId__c=imageId, imageURL__c=imageURL, Account__c=acc.Id);
		Database.SaveResult sr = Database.insert(likedImages, false);

		// Iterate through each returned result
		if (sr.isSuccess()) {
				// Operation was successful, so get the ID of the record that was processed
				System.debug('Successfully inserted account. Account ID: ' + sr.getId());
		}
		else {
				// Operation failed, so get all errors                
				for(Database.Error err : sr.getErrors()) {
						System.debug('The following error has occurred.');                    
						System.debug(err.getStatusCode() + ': ' + err.getMessage());
						System.debug('Account fields that affected this error: ' + err.getFields());
				}
		}

		PageReference pr = Page.AddedToFavorites;
		pr.getParameters().put('postId', imageId);
    // pr.getParameters().put('postImgUrl', this.postImgUrl);
		pr.setRedirect(true);
		return pr;
	}

	public static Map<String, Object> getData() {

		if (unsplashApiBearer != null) {
			// System.debug('getUserInfo');
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint('https://api.unsplash.com/me');
			request.setMethod('GET');
			request.setHeader('Authorization', 'Bearer ' + unsplashApiBearer.getValue());
			HttpResponse response = http.send(request);
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
				// userLikedImages = userLikedImagesData;

				request.setEndpoint('https://api.unsplash.com/users/'+loggedInUser+'/likes');
				request.setMethod('GET');
				request.setHeader('Authorization', 'Bearer ' + unsplashApiBearer.getValue());
				response = http.send(request);

				if (response.getStatusCode() == 200) {

					Map<String, Object> dataMap = new Map<String, Object>();
					List<Object> reqResults = (List<Object>)JSON.deserializeUntyped(response.getBody());
				
					Integer i = 0;
					for (Object r : reqResults) {
						Map<String, Object> data = (Map<String, Object>)r;
						Map<String, Object> dataImgUrls = (Map<String, Object>)data.get('urls');

						String reqRes = '{"id": "' + (String)data.get('id') + '", "imgUrl": "'+(String)dataImgUrls.get('regular')+'"}';
						Object postBody = JSON.deserializeUntyped(reqRes.replaceAll('\n', '').replaceAll('\r', ''));

						dataMap.put(String.valueOf(i), postBody);
						i++;
					}

					userLikedImages = dataMap;

				} else {
					System.debug('ERROR: ' + response.getStatusCode() + ' ' + response.getStatus());
				}
			}
		}

		if ((Apexpages.currentPage().getParameters().get('code') != null) && (username == null)){
			// System.debug('setBearerTokenCookie');
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(''+ authEndpoint
														+ '?client_id=' + client_id
														+ '&client_secret=' + client_secret
														+ '&redirect_uri=' + redirect_uri
														+ '&code=' + authCode
														+ '&grant_type=authorization_code');
			request.setMethod('POST');
			HttpResponse response = http.send(request);

			if (response.getStatusCode() == 200){
				Map<Object, Object> dataMap = new Map<Object, Object>();
				Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

				Cookie bearerToken = new Cookie('unsplashApiBearer', (String)results.get('access_token'), null,  - 1, true);
				ApexPages.currentPage().setCookies(new Cookie[]{bearerToken});

				request.setEndpoint('https://api.unsplash.com/me');
				request.setMethod('GET');
				request.setHeader('Authorization', 'Bearer ' + (String)results.get('access_token'));
				response = http.send(request);

				if (response.getStatusCode() != 200){
					System.debug('ERROR: ' + response.getStatusCode()+' ' + response.getStatus());
				} else {
					results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
					Map<String, Object> profileImgLinks = (Map<String, Object>)results.get('profile_image');
					loggedInUser = (String)results.get('username');
					username = (String)results.get('name');
					profileImg = (String)profileImgLinks.get('large');
					// userLikedImages = userLikedImagesData;
					System.debug(bearerToken);
					request.setEndpoint('https://api.unsplash.com/users/'+loggedInUser+'/likes');
					request.setMethod('GET');
					request.setHeader('Authorization', 'Bearer ' + bearerToken.getValue());
					response = http.send(request);

					if (response.getStatusCode() == 200) {

						Map<String, Object> dataMapNew = new Map<String, Object>();
						List<Object> resultsNew = (List<Object>)JSON.deserializeUntyped(response.getBody());
					
						Integer i = 0;
						for (Object r : resultsNew) {
							Map<String, Object> data = (Map<String, Object>)r;
							Map<String, Object> dataImgUrls = (Map<String, Object>)data.get('urls');

							String reqRes = '{"id": "' + (String)data.get('id') + '", "imgUrl": "'+(String)dataImgUrls.get('regular')+'"}';
							Object postBody = JSON.deserializeUntyped(reqRes.replaceAll('\n', '').replaceAll('\r', ''));

							dataMapNew.put(String.valueOf(i), postBody);
							i++;
						}

						userLikedImages = dataMapNew;

					} else {
						System.debug('ERROR: ' + response.getStatusCode() + ' ' + response.getStatus());
					}
				}
			}
		}

		if ((unsplashApiBearer != null) && (loggedInUser != null)) {
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint('https://api.unsplash.com/users/'+loggedInUser+'/likes');
			request.setMethod('GET');
			request.setHeader('Authorization', 'Bearer ' + unsplashApiBearer.getValue());
			HttpResponse response = http.send(request);

			if (response.getStatusCode() == 200) {

				Map<String, Object> dataMap = new Map<String, Object>();
				List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
			
				Integer i = 0;
				for (Object r : results) {
					Map<String, Object> data = (Map<String, Object>)r;
					Map<String, Object> dataImgUrls = (Map<String, Object>)data.get('urls');

					String reqRes = '{"id": "' + (String)data.get('id') + '", "imgUrl": "'+(String)dataImgUrls.get('regular')+'"}';
					Object postBody = JSON.deserializeUntyped(reqRes.replaceAll('\n', '').replaceAll('\r', ''));

					dataMap.put(String.valueOf(i), postBody);
					i++;
				}

				return dataMap;

			} else {
				System.debug('ERROR: ' + response.getStatusCode() + ' ' + response.getStatus());
				return null;
			}
		} else {
					Map<String, Object> dataMap = new Map<String, Object>();
					// List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());

					// Integer i = 0;
					for (Integer i = 0; i < 10; i++) {
						// Map<String, Object> data = (Map<String, Object>)r;
						// Map<String, Object> dataImgUrls = (Map<String, Object>)data.get('urls');

						String reqRes = '{"id": "' + String.valueOf(i) + '", "imgUrl": "https://dummyimage.com/1920x1080/000/ffffff.png&text=+++++++unsplashpjk+++++++"}';
						Object postBody = JSON.deserializeUntyped(reqRes.replaceAll('\n', '').replaceAll('\r', ''));

						dataMap.put(String.valueOf(i), postBody);
						// i++;
					}

					return dataMap;
		}
	}

	// public static Map<String, Object> getData(){

	// 	Map<String, Object> dataMap = new Map<String, Object>();
	// 	// List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
	
	// 	// Integer i = 0;
	// 	for (Integer i = 0; i < 10; i++) {
	// 		// Map<String, Object> data = (Map<String, Object>)r;
	// 		// Map<String, Object> dataImgUrls = (Map<String, Object>)data.get('urls');

	// 		String reqRes = '{"id": "' + String.valueOf(i) + '", "imgUrl": "IMG '+String.valueOf(i)+'"}';
	// 		Object postBody = JSON.deserializeUntyped(reqRes.replaceAll('\n', '').replaceAll('\r', ''));

	// 		dataMap.put(String.valueOf(i), postBody);
	// 		// i++;
	// 	}

	// 	return dataMap;

		// if ((unsplashApiBearer != null) && (loggedInUser != null)) {
		// 	Http http = new Http();
		// 	HttpRequest request = new HttpRequest();
		// 	request.setEndpoint('https://api.unsplash.com/users/'+loggedInUser+'/likes');
		// 	request.setMethod('GET');
		// 	request.setHeader('Authorization', 'Bearer ' + unsplashApiBearer.getValue());
		// 	HttpResponse response = http.send(request);

		// 	if (response.getStatusCode() == 200) {

		// 		Map<String, Object> dataMap = new Map<String, Object>();
		// 		List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
			
		// 		Integer i = 0;
		// 		for (Object r : results) {
		// 			Map<String, Object> data = (Map<String, Object>)r;
		// 			Map<String, Object> dataImgUrls = (Map<String, Object>)data.get('urls');

		// 			String reqRes = '{"id": "' + (String)data.get('id') + '", "imgUrl": "'+(String)dataImgUrls.get('regular')+'"}';
		// 			Object postBody = JSON.deserializeUntyped(reqRes.replaceAll('\n', '').replaceAll('\r', ''));

		// 			dataMap.put(String.valueOf(i), postBody);
		// 			i++;
		// 		}

		// 		return dataMap;

		// 	} else {
		// 		System.debug('ERROR: ' + response.getStatusCode() + ' ' + response.getStatus());
		// 		return null;
		// 	}
		// } else return null;

	// }
}