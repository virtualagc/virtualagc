#
# Python program to create GitHub issues en masse (mostly useful
# for creating a skeleton directory for a new program).
# 
# Mike Stewart 2017-01-22
# 
# The program takes as its one argument a MAIN.agc file. It determines
# all of the included AGC files and their page ranges, then creates
# a GitHub issue for each using the embedded information below.
import sys
import json
import requests
import time
from getpass import getpass

# Authentication for user filing issue (must have read/write access to
# repository to add issue to)
USERNAME = 'thewonderidiot'
PASSWORD = getpass()
MILESTONE = 6

BODY_TEXT = '''Transcribe the scans for the {} log section into its source file. This section {}.

This section has a corresponding log section in Luminary 99, from which it has been pre-populated. The two should be quite similar; look for any differences and apply them to the Luminary 116 version of the file.

Reduced quality scans can be found [here](http://www.ibiblio.org/apollo/ScansForConversion/Luminary116/). The original quality scans are available at [the Internet Archive page for Luminary 69](https://archive.org/details/luminary11600nasa). Note that the page numbers specified on this issue correspond to those printed on the original pages, not necessarily those in the filenames of the archive.org images. Look for the start of the log section; it should be marked with a "USER'S PAGE NO. 1".'''

def make_github_issue(title, body=None, assignee=None, milestone=None, labels=None):
    '''Create an issue on github.com using the given parameters.'''
    # Our url to create issues via POST
    url = 'https://api.github.com/repos/virtualagc/virtualagc/issues'
    # Create our issue
    issue = {'title': title,
            'body': body,
            'assignee': assignee,
            'milestone': milestone,
            'labels': labels}
    # Add the issue to our repository
    r = requests.post(url, json.dumps(issue), auth=(USERNAME, PASSWORD))
    if r.status_code == 201:
        print('Successfully created Issue "%s"' % title)
    else:
        print('Could not create Issue "%s"' % title)
        print('Response:', r.content)


with open(sys.argv[1],'r') as f:
    for line in f:
        if not line.startswith('$'):
            continue
        
        parts = line[1:].split('#')
        section = parts[0].strip().replace('_', ' ')[:-4]
        page_range = parts[1].strip()
        
        pages = page_range.split(' ')[-1]
        if page_range.startswith('pp'):
            pages = pages.split('-')
            page_str = "ranges from pages %s to %s" % tuple(pages)
        else:
            page_str = "consists of page %s" % pages
            page_range = 'p. ' + pages

        issue_title = "Transcribe %s (%s)" % (section, page_range)
        issue_text = BODY_TEXT.format(section, page_str)
        make_github_issue(issue_title, issue_text, None, MILESTONE, ['help wanted'])
        time.sleep(5)
