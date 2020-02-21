FUNCTION_NAME?=

.PHONY: zip
all: zip update_lambda

.PHONY: zip
zip:
	@-rm -f *.zip
	@zip function.zip lambda_function.py

.PHONY: update_lambda
update_lambda:
	aws lambda update-function-code --function-name $(FUNCTION_NAME) --zip-file fileb://function.zip