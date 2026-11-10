<?php
// Upload this file as `vps-status.php` in the SAME web root folder as `index.html` / `Rudra_Sarkar.html`
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Cache-Control: no-store');

$cores = (int)trim(@shell_exec('nproc')) ?: 4;
$cpuModel = 'AMD Ryzen 9 (' . $cores . ' vCPU)';
$cpuGhz = '3.3 GHz';
if (is_readable('/proc/cpuinfo')) {
    $cpuinfo = file_get_contents('/proc/cpuinfo');
    if (preg_match('/model name\s*:\s*(.+)/i', $cpuinfo, $cm)) {
        $cpuModel = trim($cm[1]) . ' (' . $cores . 'C)';
    }
    if (preg_match('/cpu MHz\s*:\s*([\d.]+)/i', $cpuinfo, $mhz)) {
        $cpuGhz = round(((float)$mhz[1]) / 1000, 1) . ' GHz';
    }
}

$load = function_exists('sys_getloadavg') ? sys_getloadavg() : [0.03, 0.02, 0.00];
$cpuPct = min(100, max(0, round(($load[0] / max(1, $cores)) * 100)));

// Total allocated RAM (`MemTotal - MemAvailable`, matching Ubuntu terminal & Docker/Pterodactyl usage)
$memTotal = 30.6; $memUsed = 11.2; $swapTotal = 4.0; $swapUsed = 0.0;
if (is_readable('/proc/meminfo')) {
    $mi = file_get_contents('/proc/meminfo');
    preg_match('/MemTotal:\s+(\d+)/', $mi, $mt);
    preg_match('/MemAvailable:\s+(\d+)/', $mi, $ma);
    preg_match('/SwapTotal:\s+(\d+)/', $mi, $st);
    preg_match('/SwapFree:\s+(\d+)/', $mi, $sf);
    if (!empty($mt[1])) {
        $totalKb = (float)$mt[1];
        $availKb = !empty($ma[1]) ? (float)$ma[1] : ($totalKb * 0.6);
        $usedKb  = max(0, $totalKb - $availKb);
        $memTotal = round($totalKb / 1048576, 1);
        $memUsed  = round($usedKb / 1048576, 2);
    }
    if (isset($st[1])) {
        $swapTotal = round(((float)$st[1]) / 1048576, 1);
        $swapUsed = round(max(0, ((float)$st[1] - (float)($sf[1] ?? 0)) / 1048576), 2);
    }
}

$diskTotal = round(@disk_total_space('/') / 1073741824, 0) ?: 103;
$diskFree  = round(@disk_free_space('/') / 1073741824, 0) ?: 84;
$diskUsed  = max(1, $diskTotal - $diskFree);

$uptimeSec = 43109;
if (is_readable('/proc/uptime')) {
    $u = explode(' ', file_get_contents('/proc/uptime'));
    $uptimeSec = (int)$u[0];
}

$bw = 'Live Port';
if (is_readable('/proc/net/dev')) {
    $nd = file_get_contents('/proc/net/dev');
    if (preg_match('/eth0:\s*(\d+)\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+(\d+)/', $nd, $nm)) {
        $rxMib = round(((float)$nm[1]) / 1048576, 0);
        $txMib = round(((float)$nm[2]) / 1048576, 1);
        $bw = 'RX ' . $rxMib . ' MiB / TX ' . $txMib . ' MiB';
    }
}

echo json_encode([
    'name'      => gethostname() ?: ($_SERVER['HTTP_HOST'] ?? 'demonix-vps'),
    'region'    => 'Demonix VPS · Live Kernel',
    'cores'     => $cores,
    'cpuGhz'    => $cpuGhz,
    'cpuModel'  => $cpuModel,
    'cpu'       => $cpuPct,
    'load1'     => $load[0],
    'load5'     => $load[1],
    'load15'    => $load[2],
    'ramUsed'   => $memUsed,
    'ramTotal'  => $memTotal,
    'diskUsed'  => $diskUsed,
    'diskTotal' => $diskTotal,
    'swapUsed'  => $swapUsed,
    'swapTotal' => $swapTotal,
    'uptimeSec' => $uptimeSec,
    'bw'        => $bw,
    'os'        => php_uname('s') . ' ' . php_uname('r'),
    'ip'        => $_SERVER['SERVER_ADDR'] ?? ($_SERVER['HTTP_HOST'] ?? 'Auto')
]);
