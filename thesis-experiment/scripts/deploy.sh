ssh ssh.pythonanywhere.com /bin/bash -l << EOF
  cd ~/thesis-experiment/thesis-experiment/backend/
  workon backend
  git pull
  python manage.py collectstatic --noinput
  python manage.py migrate
EOF