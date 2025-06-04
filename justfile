build:
  make

format:
  terraform fmt -recursive

lint:
  shellcheck *.sh
  tflint
