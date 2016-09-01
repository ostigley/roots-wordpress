build:
	coffee --compile --output lib/ src/

clean:
	rm -rf lib

publish:
	make build
	npm publish .
	make unbuild

coveralls:
	NODE_ENV=test istanbul cover ./node_modules/mocha/bin/_mocha --report lcovonly -- -R spec && cat ./coverage/lcov.info | ./node_modules/coveralls/bin/coveralls.js && rm -rf ./coverage