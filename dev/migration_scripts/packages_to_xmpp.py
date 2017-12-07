#!/usr/bin/python
import os
import sys
import re
import shutil
import json

old_packages_folder = os.path.join('/', 'var', 'lib', 'pulse2', 'old_packages')
packages_folder = os.path.join('/', 'var', 'lib', 'pulse2', 'packages')
xmppdeploy_template = os.path.join('/', 'root', 'xmppdeploy.json.in')

def run_checks():
    if not os.path.isfile(xmppdeploy_template):
        sys.exit('ERROR: The template JSON file %s could not be found.' % xmppdeploy_template)

    if os.listdir(packages_folder) == []:
        sys.exit('ERROR: %s folder is empty.' % packages_folder)

    # Create old_packages folder
    if not os.path.exists(old_packages_folder):
        os.makedirs(old_packages_folder)


def is_uuid(uuid_string):
    # Check that uuid_string is a valid UUID
    regex = re.compile('^[a-f0-9]{8}-?[a-f0-9]{4}-?[a-f0-9]{4}-?[a-f0-9]{4}-?[a-f0-9]{12}\Z', re.I)
    match = regex.match(uuid_string)
    return bool(match)

def transform_package(folder_name):
    # Transform the package to XMPP format
    print('Transforming package %s to XMPP format' % folder_name)
    try:
        # Extract data from conf.json
        json_file = open(os.path.join(old_packages_folder, folder_name, 'conf.json'), 'r')
        old_package_data = json.load(json_file)
        #print 'JSON data:'
        #print json.dumps(old_package_data, sort_keys=True, indent=4, separators=(',', ': '))

        # Create new folder and copy files
        if not os.path.exists(os.path.join(packages_folder, folder_name)):
            os.makedirs(os.path.join(packages_folder, folder_name))
        # Copy all files except xmppdeploy.json, xmppdeploy.sh, xmppdeploy.bat and MD5SUMS
        ignored_files = ['xmppdeploy.json', 'xmppdeploy.bat', 'xmppdeploy.sh', 'MD5SUMS']
        for files in os.listdir(os.path.join(old_packages_folder, folder_name)):
            if files not in ignored_files:
                shutil.copy2(os.path.join(old_packages_folder, folder_name, files), os.path.join(packages_folder, folder_name))

        # Extract template
        template_file = open(xmppdeploy_template, 'r')
        template_data = json.load(template_file)
        # And replace values in template
        template_data['info']['software'] = old_package_data['name']
        template_data['info']['description'] = old_package_data['description']
        template_data['info']['version'] = old_package_data['version']
        template_data['info']['name'] = old_package_data['name'] + ' ' + old_package_data['version']
        template_data['win']['sequence'][0]['script'] = old_package_data['commands']['command']['command']
        #print 'JSON data:'
        #print json.dumps(template_data, sort_keys=True, indent=4, separators=(',', ': '))
        xmppdeploy_file = os.path.join(packages_folder, folder_name, 'xmppdeploy.json')
        with open(xmppdeploy_file, 'w') as outfile:
            json.dump(template_data, outfile, sort_keys=True, indent=4, separators=(',', ': '))
        print('%s file generated' % xmppdeploy_file)
        return

    except:
        print "Unexpected error:", sys.exc_info()[0]
        raise


run_checks()

# Move all packages to old_packages folder
for folder in os.listdir(packages_folder):
    print('Moving %s to %s' % (folder, old_packages_folder))
    try:
        shutil.move(os.path.join(packages_folder, folder), old_packages_folder)
    except:
        print "Unexpected error:", sys.exc_info()[0]
        raise

for folder in os.listdir(old_packages_folder):
    print '----------------------------------------'
    print('Processing folder %s' % folder)
    if is_uuid(folder) and os.path.isfile(os.path.join(old_packages_folder, folder, 'conf.json')):
        # Transform the package to XMPP format
        transform_package(folder)
    else:
        # Not a valid package folder
        print('ERROR: %s is not a valid package folder' % folder)


# All packages generated
print('========================================')
print('You must now restart pulse2-package-server:\n\t systemctl restart pulse2-package-server.service')
