//
//  Constants.swift
//  Spotify
//
//  Created by 이창준 on 2023/02/20.
//

import Foundation

struct Constants {
    static let clientID = "8c9858d0e360420a9679ef9a02845b78"
    static let clientSecret = "aee33727f3f048179113ce8bbc9c10f9"
    static let tokenAPIURL = "https://accounts.spotify.com/api/token"
    static let redirectURI = "REDIRECT_URL" // Can be your own website url
    static let scopesArray = ["user-read-private",
                               "playlist-modify-public",
                               "playlist-read-private",
                               "playlist-modify-private",
                               "user-follow-read",
                               "user-read-email"
    ]
//Add scopes to capture different user accesses
}
