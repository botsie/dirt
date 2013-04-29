

import cookielib
import urllib
import urllib2
       
# creates a cookie for the rtserver with the credentials given at initialization.
# define your credentials here
access_user = 'biju.ch'
access_password = '1qaz@wsx'
       
# here is the RequestTracker URI we try to access
uri = 'https://sysrt.ops.directi.com/REST/1.0/ticket/123/show'
       
# trying login on rt server
cj = cookielib.LWPCookieJar()
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
urllib2.install_opener(opener)
data = {'user': access_user, 'pass': access_password}
ldata = urllib.urlencode(data)
login = urllib2.Request(uri, ldata)
try:
   response = urllib2.urlopen(login)
   print response.read()
   print "login successful"
except urllib2.URLError:
   # could not connect to server
   print "Not able to login"

