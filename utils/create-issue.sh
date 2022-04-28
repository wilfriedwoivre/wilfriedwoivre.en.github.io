
for entry in `ls ./_posts | head -2`; do
    if grep -w 'githubcommentIdtoreplace: ' "./_posts/$entry"; then
        echo "$entry need to be updated"

        title=$(grep -w 'title:' "./_posts/$entry")
        issueTitle="$(echo "${title/"title:"/""}"  | xargs echo -n)"

        result=$(curl --request POST --url https://api.github.com/repos/wilfriedwoivre/wilfriedwoivre.en.github.io/issues --header 'authorization: Bearer $GITHUBTOKEN' --header 'Content-Type: application/json' --data "{\"title\": \"$issueTitle\", \"body\": \"This issue was automatically created by the GitHub Action workflow\" }")
        echo $result
        issueNumber=$(result | jq '.number')
        echo "$issueNumber"

        sed -i "s/githubcommentIdtoreplace:/comments_id:$issueNumber/" "./_posts/$entry"
    else
        echo "$entry has already an assigned issue"
    fi
done