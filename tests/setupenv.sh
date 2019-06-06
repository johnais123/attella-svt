get_abs_filename() {
  # $1 : relative filename
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}


SCRIPT="${BASH_SOURCE[0]}"

echo Setting PYTHONPATH, TEST_ROOT
THIS_PATH=`get_abs_filename "$SCRIPT"`
PROJECT="test"
TEST_ROOT=$(dirname "$THIS_PATH")
PROJECT_DIR="$TEST_ROOT"
PYTHONPATH=$PROJECT_DIR:$PROJECT_DIR/../lib
PATH=./:$PROJECT_DIR:$PATH
PYTHONIOENCODING="UTF-8"
export PYTHONPATH
export PATH 
export PYTHONIOENCODING

cat >../.env <<EOL
PATH=$PATH
PYTHONPATH=$PYTHONPATH
PYTHONIOENCODING=$PYTHONIOENCODING
EOL
