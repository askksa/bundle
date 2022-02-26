#!/usr/bin/python

import os
import json
import vim

def parsing_rules(path):

    if os.access(path, os.F_OK):
        print("cscope filter rules config file => %s" % path)
        f = open(path, "rb")
        fbuf = f.read()
        json_data = json.loads(fbuf.decode("utf-8"))

        cs_search_dirs = json_data["cs_search_dirs"]
        cs_ignore_dirs = json_data["cs_ignore_dirs"]

        cs_interested_files = json_data["cs_interested_files"]
        cs_ignore_files = json_data["cs_ignore_files"]

        search_dir_str = "\|".join(cs_search_dirs)
        ignore_dir_str = "\|".join(list(i+"$" for i in cs_ignore_dirs))
        interested_file_str = "\|".join(list(i+"$" for i in cs_interested_files))
        ignore_file_str = "\|".join(list(i+"$" for i in cs_ignore_files))

        vim.command("call CscopeMergeFilterRules('%s', '%s', '%s', '%s')" % (search_dir_str, ignore_dir_str, interested_file_str, ignore_file_str))
    else:
        print("invalid filter rules path => %s" % path)

if __name__ == "__main__":
    parsing_rules("./filter_rules.json")

