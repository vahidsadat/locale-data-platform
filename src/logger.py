import logging
import sys


def setup_logger(level: int = logging.INFO) ->None:

    log_format = "%(asctime)s [%(levelname)s] %(name)s (%(filename)s:%(lineno)d) - %(message)s"
    dateformat = "%Y-%m-%d %H:%M:%S"
    logging.basicConfig(
        level= level,
        format= log_format,
        datefmt=dateformat,
        handlers=[
            logging.StreamHandler(sys.stdout),
        ],
    )

