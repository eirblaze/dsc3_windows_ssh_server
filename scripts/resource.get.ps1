$config = Get-Content .\configs\ssh-server.dsc.json | ConvertFrom-Json

foreach ($r in $config.resources) {

    # 入れ子構造を正しく Hashtable に変換する関数
    function ConvertTo-Hashtable($obj) {
        if ($obj -is [System.Collections.IEnumerable] -and $obj -isnot [string]) {
            $list = @()
            foreach ($item in $obj) {
                $list += ConvertTo-Hashtable $item
            }
            return $list
        }

        if ($obj -is [pscustomobject]) {
            $ht = @{}
            foreach ($p in $obj.PSObject.Properties) {
                $ht[$p.Name] = ConvertTo-Hashtable $p.Value
            }
            return $ht
        }

        return $obj
    }

    $input = ConvertTo-Hashtable $r.input

    dsc resource get --resource $r.resource --input $input
}
