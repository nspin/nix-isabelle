IFS=$'\n'
echo '{'
for line in $(grep -v -e '^#' -e '^$' names.txt); do
    IFS=' '
    split=($line)
    group=${split[0]}
    name=${split[1]}
    url="https://isabelle.in.tum.de/components/${name}.tar.gz"
    sha256=$(curl $url | sha256sum | cut -d ' ' -f 1)
    echo "  $group.\"$name\" = \"$sha256\";"
done
echo '}'
