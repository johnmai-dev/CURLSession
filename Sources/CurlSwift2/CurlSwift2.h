//
//  CurlSwift.h
//  CURLSession
//
//  Created by John Mai on 2024/11/30.
//

#include <curl/curl.h>

//// MARK: - curl_easy_setopt
//
//static inline CURLcode curlEasySetoptString(CURL *handle, CURLoption option, const char *value);
//static inline CURLcode curlEasySetoptLong(CURL *handle, CURLoption option, long value);
//static inline CURLcode curlEasySetoptVoid(CURL *handle, CURLoption option, void *value);
//static inline CURLcode curlEasySetoptHeaderCallback(CURL *handle, curl_write_callback callback);
//static inline CURLcode curlEasySetoptWriteCallback(CURL *handle, CURLoption option, curl_write_callback callback);
//static inline CURLcode curlEasySetoptSlist(CURL *handle, CURLoption option, struct curl_slist *list);
//static inline CURLcode curlEasySetoptProxytype(CURL *handle, CURLoption option, curl_proxytype value);
//
//// MARK: - curl_easy_getinfo
//
//static inline CURLcode curlEasyGetInfoLong(CURL *handle, CURLINFO info, long *value);



static inline CURLcode curlEasySetoptString(CURL *handle, CURLoption option, const char *value) {
    return curl_easy_setopt(handle, option, value);
}

static inline CURLcode curlEasySetoptLong(CURL *handle, CURLoption option, long value) {
    return curl_easy_setopt(handle, option, value);
}

static inline CURLcode curlEasySetoptVoid(CURL *handle, CURLoption option, void *value) {
    return curl_easy_setopt(handle, option, value);
}

static inline CURLcode curlEasySetoptHeaderCallback(CURL *handle, curl_write_callback callback) {
    return curl_easy_setopt(handle, CURLOPT_HEADERFUNCTION, callback);
}

static inline CURLcode curlEasySetoptWriteCallback(CURL *handle, CURLoption option, curl_write_callback callback) {
    return curl_easy_setopt(handle, option, callback);
}
    

static inline CURLcode curlEasySetoptSlist(CURL *handle, CURLoption option, struct curl_slist *list) {
    return curl_easy_setopt(handle, option, list);
}

static inline CURLcode curlEasySetoptProxytype(CURL *handle, CURLoption option, curl_proxytype value) {
    return curl_easy_setopt(handle, option, value);
}

// MARK: - curl_easy_getinfo

static inline CURLcode curlEasyGetInfoLong(CURL *handle, CURLINFO info, long *value) {
    return curl_easy_getinfo(handle, info, value);
}
    
    
