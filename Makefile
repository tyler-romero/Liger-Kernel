.PHONY: test checkstyle test-convergence all env-report


all: test test-convergence checkstyle

# Command to run pytest for correctness tests
test:
	python -m pytest --disable-warnings test/ --ignore=test/convergence


# Command to run flake8 (code style check), isort (import ordering), and black (code formatting)
# Subsequent commands still run if the previous fails, but return failure at the end
checkstyle:
	flake8 .; flake8_status=$$?; \
	isort .; isort_status=$$?; \
	black .; black_status=$$?; \
	if [ $$flake8_status -ne 0 ] || [ $$isort_status -ne 0 ] || [ $$black_status -ne 0 ]; then \
		exit 1; \
	fi

# Command to run pytest for convergence tests
# We have to explicitly set HF_DATASETS_OFFLINE=1, or dataset will silently try to send metrics and timeout (80s) https://github.com/huggingface/datasets/blob/37a603679f451826cfafd8aae00738b01dcb9d58/src/datasets/load.py#L286
test-convergence:
	HF_DATASETS_OFFLINE=1 python -m pytest --disable-warnings test/convergence

# Command to report details about the current environment. Useful for bug reports.
env-report:
	@echo "Environment Report:"
	@echo "-------------------"
	@echo -n "Operating System: "; uname -a
	@echo -n "Python version: "; python --version
	@echo -n "PyTorch version: "; python -c "import torch; print(torch.__version__)"
	@echo -n "Triton version: "; python -c "import triton; print(triton.__version__)"
	@echo -n "Transformers version: "; python -c "import transformers; print(transformers.__version__)"
