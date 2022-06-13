import sys
import hashlib


def main():
    try:
        file_path = sys.argv[1]
    except IndexError as error:
        raise RuntimeError('I need a file path to get the hash from!') from error
    try:
        hasher_name = sys.argv[2]
    except IndexError:
        hasher_name = 'sha256'

    try:
        hasher = getattr(hashlib, hasher_name.lower())
    except AttributeError:
        raise RuntimeError('Could not get hash algorithm "%s"! Available are:\n %s' % ', '.join(hashlib.algorithms_available))

    binary = True
    block_size = 2**16
    mode = 'rb' if binary else 'r'

    with open(file_path, mode) as file_object:
        buffer_object = file_object.read(block_size)
        hasherobj = hasher()
        len_buf = len(buffer_object)
        while len_buf > 0:
            if binary:
                hasherobj.update(buffer_object)
            else:
                hasherobj.update(buffer_object.encode('utf8'))
            buffer_object = file_object.read(block_size)
            len_buf = len(buffer_object)
    print(hasherobj.hexdigest())


if __name__ == '__main__':
    # sys.argv.append(r'C:\Users\eric\Downloads\AutoHotkey_1.1.34.03_setup(1).exe')
    main()
