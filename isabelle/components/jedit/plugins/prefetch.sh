echo '{'
for name in $(cat names.txt); do
    url="http://prdownloads.sourceforge.net/jedit-plugins/${name}.tgz";
    sha256=$(curl $url | sha256sum | cut -d ' ' -f 1)
    echo "  \"$name\" = \"$sha256\";"
done
echo '}'

# jedit-5.5.0-patched
# kappalayout.jar
# idea-icons.jar
# jsr305-2.0.0.jar
