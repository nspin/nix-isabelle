echo '{'
for name in $(cat names.txt); do
    url="https://isabelle.in.tum.de/components/${name}.tar.gz"
    sha256=$(curl $url | sha256sum | cut -d ' ' -f 1)
    echo "  \"$name\" = \"$sha256\";"
done
echo '}'
