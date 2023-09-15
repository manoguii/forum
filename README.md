# Errors

### EACCES: permission denied
> Serialized Error: { errno: -13, code: 'EACCES', syscall: 'scandir', path: '/home/manogui/www/node-js/nest-clean/database/pg' }

```bash
sudo chmod -R 777 data/pg
```

# Setup

> Generate private and public key using rsa256 and add in .env file converting to base64 format.

## Generate a Private Key:
Use the following OpenSSL command to generate a 2048-bit RSA private key:

```bash
openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048
```

This command generates an RSA private key and saves it to a file named private_key.pem.

## Generate the Corresponding Public Key:
Once the private key is generated, you can use it to generate the corresponding public key:

```bash
openssl rsa -pubout -in private_key.pem -out public_key.pem
```

This command extracts the public key from the private key and saves it to a file named public_key.pem.

## Encode File to Base64:
Use the following command to encode the content of a file to base64 and display the result in the terminal:

```bash
base64 -w 0 < input_file > output_file
```

Replace input_file with the path to the file you want to convert, and output_file with the desired name for the base64-encoded output file.

The -w 0 option tells base64 not to insert line breaks in the output, which is useful for generating a single continuous line of base64-encoded data.

For example, if you have a file named data.txt and you want to encode its content to base64 and save it to encoded_data.txt, you would run:

```bash
base64 -w 0 < data.txt > encoded_data.txt
```

The base64-encoded content will be saved in the encoded_data.txt file.


