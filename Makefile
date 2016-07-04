build:
	node_modules/.bin/coffee -c *.coffee
clean:
	rm -f *.js
test:
	node_modules/.bin/mocha
