/**
     * This functions generates a token as done in office 365
     * @return mixed|string
     */
    private function getOffice365MxToken($domain)
    {
        $delimiter = '0'; // delimiter between the domain part and the hyphen replacement part

        $token = $domain;
        $hyphenReplaceToken = '';

        // split domain string into chunks of 4 chars
        $chunkSize = 4;
        $chunks = str_split($token, $chunkSize);

        // transform the hyphens (their position) in the domain name to an alphanumerical character string
        $skipCount = 0;
        $intOfA = ord('a'); // get the decimal value of the letter 'a' as start value
        foreach($chunks as $chunk){
            $digit = $intOfA;
            for ($i = 0; $i < $chunkSize; $i++){
                if('-' === $chunk[$i]){
                    $digit += pow(2, $i);
                }
            }
            if($intOfA === $digit){ // if the value is a it means no hyphen was found
                $skipCount++;
                continue;
            }
            if (0 !== $skipCount) {
                $hyphenReplaceToken .= $skipCount;
            }
            $hyphenReplaceToken .= chr($digit);
            $skipCount = 0; // rewind skip count
        }

        if(strlen($hyphenReplaceToken) > 0){
            $token .= $delimiter . $hyphenReplaceToken;
        }

        $token = str_replace('-', '', $token); // remove - from domain name
        $token = str_replace('.', '-', $token); // replace dots with -

        return $token;
    }
