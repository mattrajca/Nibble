from google.appengine.ext import db
from google.appengine.ext import webapp
from google.appengine.ext.webapp import template
from google.appengine.ext.webapp import util

import os
import simplejson as json

class App(db.Model):
	identifier = db.StringProperty()
	name = db.StringProperty()
	description = db.StringProperty()
	source = db.TextProperty()


class AppsHandler(webapp.RequestHandler):
	def get(self):
		parsedApps = []
		
		for app in App.all():
			parsedApp = {
				'identifier': app.identifier,
				'name': app.name,
				'description': app.description
			}
			
			parsedApps.append(parsedApp)
		
		self.response.out.write(json.dumps(parsedApps))


class MainHandler(webapp.RequestHandler):
	def get(self):
		self.response.out.write('The Byte Shop')


class ListSourceHandler(webapp.RequestHandler):
	def get(self):
		identifier = self.request.get('identifier')
		
		if not identifier:
			return
		
		app = App.gql("WHERE identifier = :1", identifier).get()
		
		if not app:
			return
		
		self.response.out.write(app.source)


class UploadHandler(webapp.RequestHandler):
	def get(self):
		path = os.path.join(os.path.dirname(__file__), 'templates/upload.html')
		self.response.out.write(template.render(path, {} ))
	
	def post(self):
		name = self.request.get('name')
		description = self.request.get('description')
		identifier = self.request.get('identifier')
		source = self.request.get('source')
		
		app = App()
		app.name = name
		app.description = description
		app.identifier = identifier
		app.source = db.Text(source)
		app.put()
		
		self.response.out.write("OK")


def main():
	application = webapp.WSGIApplication([('/', MainHandler),
										  ('/apps', AppsHandler),
										  ('/listSource', ListSourceHandler),
										  ('/upload', UploadHandler)],
										debug=True)
	util.run_wsgi_app(application)


if __name__ == '__main__':
	main()
