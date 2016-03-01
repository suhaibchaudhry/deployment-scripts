#!/bin/bash
echo -e "which theme do you want? (enter full theme name):"
n=1
for i in $(ls templates/themes/); do
  echo $n")" $i
  ((n++))
done

echo -e "\n"
read userTheme

case $userTheme in
  '1')
    echo -e "copying awpurology theme..."
    ;;
  '2')
    echo -e "copying test theme..."
    ;;
  *)
    echo "enter a valid thene name: "
    ;;
esac
