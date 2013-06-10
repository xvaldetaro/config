import multiprocessing

bind = "127.0.0.1:<app_port>"
workers = multiprocessing.cpu_count() * 2 + 1
user = "<user>"
loglevel = "debug"
accesslog = "-"
errorlog = "-"
proc_name = "gunicorn_<proj_name>"