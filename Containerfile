FROM treg.cathay-ins.com.tw/runner-image/python-git:3.12.13-slim
WORKDIR /app
COPY requirements.txt .
RUN pip config set global.index-url http://cicdadm:cicdadm@Cathay1113@10.178.42.21:8081/repository/pypi-proxy/simple
RUN pip config set global.trusted-host 10.178.42.21:8081
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8080
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8080", "app:app"]