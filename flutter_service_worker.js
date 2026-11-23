'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "d21cba289a8beaa976d5cc9f7fdfbad9",
".git/config": "432e71799241fc99a19ead00b0215c27",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "11dbb1c804f285ba70c36dfbe6ad378a",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "98210e25c891312009541f6f7519fa5c",
".git/logs/refs/heads/gh-pages": "b262f274a609f8aa9519aa8f18c53ba7",
".git/logs/refs/remotes/origin/gh-pages": "b48972eb66b68f3c04850a8ce1d6f132",
".git/objects/03/eaddffb9c0e55fb7b5f9b378d9134d8d75dd37": "87850ce0a3dd72f458581004b58ac0d6",
".git/objects/06/c6c087449d71af482f9dd6e0959b000a2c8a9d": "0dde3f57a485773cd517a60e9121dfc0",
".git/objects/07/e0c2a07e7df374339b471239fcbfbdfc73e488": "ca3ed2a591f73f51fcc02d0c2999f603",
".git/objects/08/32d0db2def1613c1c45aa4fe9156a1c6b7d589": "e05df183e5eeaddf39672a2516f9c41d",
".git/objects/09/d9cd4b830ca6acb1a24372f8e5766e49f28cd4": "01d6cd92728161b69a304cb9e30297a9",
".git/objects/0b/6a2815ce6d8efd98894d927d9d192c709606c5": "4420fe47c0f853376963dae61ceca5be",
".git/objects/10/3e81bd8408e6b15c6327c1aa328627faef2514": "b35598f1301bed0637ac394525e0b117",
".git/objects/10/dab7b5cfa0835967ba3ce55930756f1afa6fb3": "3601698b3f4af5837bd3c5f1eb7e9c90",
".git/objects/16/c2f6c22029b9d87e5b0f9e64d36ba368b36bbb": "824ae1c0173cb499fae6e466658e992f",
".git/objects/18/9932c763c17061376d35fed11aa813f6b26c13": "f88801b7aa776169f4f677a6eeaa053a",
".git/objects/18/b5d881dfedff9e4b141fc0ab80a17f8102d08d": "cbc43848b5d153aa7aa8feed8044b6b1",
".git/objects/1e/c5714e9ceee822d5a794ebf810498685ed74bc": "562f9e07d002e918fae378531ab68bae",
".git/objects/1f/45b5bcaac804825befd9117111e700e8fcb782": "7a9d811fd6ce7c7455466153561fb479",
".git/objects/20/99374206eb3acd1a1971b1f801e3a1fbd36db7": "8a6afc92eb81509f8375f4a623942b1d",
".git/objects/25/8b3eee70f98b2ece403869d9fe41ff8d32b7e1": "05e38b9242f2ece7b4208c191bc7b258",
".git/objects/25/97ea00aadb43fb5852113605b2390fab06b4f5": "ea8a36a2c6b4c107cabe92f794580a0f",
".git/objects/2d/7db24b2d7619dedf20d345476d2a526d4f706e": "319a1f5ae77002bd90e01715a6779245",
".git/objects/32/5a1323f7279a23e2ab415df435361b15f9e7fd": "33ee394616dcd408eaf38286733ca293",
".git/objects/32/aa3cae58a7432051fc105cc91fca4d95d1d011": "4f8558ca16d04c4f28116d3292ae263d",
".git/objects/3a/7525f2996a1138fe67d2a0904bf5d214bfd22c": "ab6f2f6356cba61e57d5c10c2e18739d",
".git/objects/3c/7a409b1a1d863ff61dc0df6a9699b022f28ec6": "fad3cc4f54f2cbe010e863abb67ca430",
".git/objects/3c/fc8848eb815726d44053a62c176277fd7454a3": "09f23b5f521fbe611968810c11e7f63e",
".git/objects/40/0d5b186c9951e294699e64671b9dde52c6f6a0": "f6bd3c7f9b239e8898bace6f9a7446b9",
".git/objects/41/2c0caf942588cad72f0ede05a0fb4526244187": "e4bf0cb03fb3a62d72acf421e5e0f798",
".git/objects/41/5c059c8094b888b0159fdedfd4e3cb08a8028e": "86914685ccd40e82a7fe5b70459fb9f7",
".git/objects/44/a8b8e41b111fcf913a963e318b98e7f6976886": "5014fdb68f6b941b7c134a717a3a2bc6",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/48/92d33a925c282d227ee4244477994957daa31c": "d2941a258b671e45aaecd4e8b07829a8",
".git/objects/51/85eb3f025303be33e3661bba066bd5c2b78366": "c2abe6233a0ddf3b3522de9c551c8f79",
".git/objects/54/db0a47a4bfaa6b4bc3950a4287c17628a40ef9": "d69ae8bc51d2d105145ad82da860179f",
".git/objects/55/42575d3be8a4c4e5472d357938fbcec921a648": "1f43eb04f9ed845f6d44c9b53e8e6acd",
".git/objects/55/e404ca4ac1c03caf974b047e77b8f17c3c25f4": "bb3b06a532404e4d1d3c8a16d1b7a14c",
".git/objects/5c/18d2dfa2e752ba2727c60d0ac9fd71a2971866": "c13e9ffba0619a3a220993218b9108e4",
".git/objects/5e/e63f64ccace3ee1b969dfca7a2bafaebd71a70": "76f6e669fc8b454d77bcbcfbd0e8dea5",
".git/objects/63/1980911b89f97bac49f31ce98bc52167db9752": "2fbd3659be31263216ad7089aa39e8be",
".git/objects/69/dd618354fa4dade8a26e0fd18f5e87dd079236": "8cc17911af57a5f6dc0b9ee255bb1a93",
".git/objects/6b/e909fbf40b23748412f0ea89bf0fae827ed976": "5f118419157d9534688915220cc803f7",
".git/objects/6c/633a40576dee72a2f9fd3db5587dbebb6610f8": "d25e6f7e9c5900300fdab2d0bbf0fc1f",
".git/objects/73/a000d16e8d52d3f2e3d4ca3ab464451068c05c": "f77468a56fc844de9be3d59409bdc2d6",
".git/objects/76/0ff6af40e4946e3b2734c0e69a6e186ab4d8f4": "009b8f1268bb6c384d233bd88764e6f8",
".git/objects/7e/f3715b29b1026116fcdaa7809b87ca7e91099c": "0287d87d04fecddd778ff525fbf527f2",
".git/objects/84/0516208d35dcb4298847ab835e2ef84ada92fa": "36a4a870d8d9c1c623d8e1be329049da",
".git/objects/85/6a39233232244ba2497a38bdd13b2f0db12c82": "eef4643a9711cce94f555ae60fecd388",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/8a/87fe4b0790e12d37c62caeaa49331109a8674f": "0612f1a281511afa5a250a3f6e6e4eca",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/8c/99266130a89547b4344f47e08aacad473b14e0": "41375232ceba14f47b99f9d83708cb79",
".git/objects/8f/e7af5a3e840b75b70e59c3ffda1b58e84a5a1c": "e3695ae5742d7e56a9c696f82745288d",
".git/objects/90/49692a32c0fc558fbf2820a353dc3d3ac8e103": "85cb5a6620b93941c5dd5848fad59e2d",
".git/objects/90/bcfcf0a77ab618a826db0fd8b0942963b653af": "fc109675cdf1233dd6599a4c3c0a7a69",
".git/objects/92/76649c3af8e77705606100c165a16ef33e9124": "407b020cac7995b09b98ed017c68d3e5",
".git/objects/92/eab450609b7dc5d076ddf6c8416de8209373e0": "9b3d4cb7f5916a87f36a18b466ea7ac4",
".git/objects/95/9312e269e33cc5835fc65b6e83635dd8d0a07a": "a6f10f922078d46272c8ef6b20c7d60a",
".git/objects/96/9b6c948d374665a57ba871da37c48c02dc2f2f": "9fb17c6c91871a010ad8b2ba32f25cd7",
".git/objects/98/57c9b3b0448c92818efc5fda0f206b21914168": "ecbde07c564dabbec0f249821051b8af",
".git/objects/9a/2c78165e8176fd5480a7403e5d1cdba35a3ccc": "3809fd8ff92ff8f5ec7eb064402490a5",
".git/objects/a0/315139ed1aa3b2d48889c2d594c3f3f6a74013": "1b7ca79fc192a545e137d8acaae8af02",
".git/objects/a6/98ca009ab565e5fe532a4d1fb1fdbe1a8ab4be": "362b487a9c020c2355e4be63bd44280b",
".git/objects/ad/4c0ba9842f4de544316a62269732d33f652961": "d2648c4f7ac6a01d24dedabffef3980b",
".git/objects/b1/5ad935a6a00c2433c7fadad53602c1d0324365": "8f96f41fe1f2721c9e97d75caa004410",
".git/objects/b3/77efc36ba50f69babefc709da14bcd422d97c7": "6c9d98c170d3f6aab4453713cb334868",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/ba/162e7de80ce68107d1304b881bd822e61858ce": "3b8dccfa818b3933e1f00c13e3960a3e",
".git/objects/ba/3d04b1ba1fffaba96aaee94834acff3325ad3c": "5c2d4cda52db4e3fdfdaee7367ee0d52",
".git/objects/ba/5317db6066f0f7cfe94eec93dc654820ce848c": "9b7629bf1180798cf66df4142eb19a4e",
".git/objects/c5/7d0f7fe96d12865dab3fdc5f235af3cf15cad7": "54df89b8cf3a35bb4288ffa79a6cd8cb",
".git/objects/d0/23371979cf1e985205df19078051c10de0a82d": "700b71074bad7afee32068791dec7442",
".git/objects/d3/4b9e509a7f0d4c7ee677c1bda5f0f29dc78fa5": "578da1c33410e95b834792c4dfe6396e",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d5/12d7a100c52193558e3958f638e41fbdb29f20": "bb2fe66c31bcf2c5962f7a37ea0d8231",
".git/objects/d5/80ce749ea55b12b92f5db7747290419c975070": "8b0329dbc6565154a5434e6a0f898fdb",
".git/objects/d5/bb50b3c3bc534b51ba035a5e8495ba7af5025b": "81d30e6f235d2cd1960b1a0d917b3043",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d7/6af95e8c2f33e4de4ced9f146813e96a8200ad": "a29fea834f032dbc77c8f198febc4820",
".git/objects/d9/68d08883005f5d0efe9734900157beb8719128": "9a40ab5a0c547d9efb9fe27f8a390ed4",
".git/objects/da/fd65422747502c19b5c74b4230282644d2169c": "d8a62caf99a372ff6c7692e143787ce3",
".git/objects/db/23ce1fa61c287987af12f676a6bed3f73416d3": "82c89cb7e1f62212b59b6a7f71be00ea",
".git/objects/e2/ad3a09380fd3b62eea37493ad1676665edd583": "04d86f2a5b17801f58ad8f364152a2f3",
".git/objects/e9/2973b485a9a61a0e438644ca0f619df4219e93": "0c8894e1e74726c5763fdcdce5ad3d29",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ed/ed3c21b7334a65647eb71a9f73599c1607188d": "315cb4cd211a8ef715a9d64dfd47da40",
".git/objects/f0/32e6cd2da6288b5ed689d4fb20a26ffd12f0be": "46ce7dd413c99c35130a101d4103d74e",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f7/f5775004bcfb0626f8a3b2e2606ff5643d0e2f": "728373336130462f0d2285136300a4f5",
".git/objects/fa/7d2974b76e4853a6d7dd99e48e12253170ca2a": "5aa51e8bdc3f318e5cb0f1f7afe5e70f",
".git/refs/heads/gh-pages": "42e4471fb3587f05d727af204ea16e3c",
".git/refs/remotes/origin/gh-pages": "67ec23bf91f20da9089d815d1a6c1e4a",
"assets/AssetManifest.bin": "b357cb8833ff799e3fa14aa4f06328be",
"assets/AssetManifest.bin.json": "c9ef2ecebd0e3c00031658afef43feb0",
"assets/AssetManifest.json": "ad2266483519d98edad236e9b1614fba",
"assets/assets/images/app_icon.png": "d2e0f3bb6c52ccf7156e7f85b48de22d",
"assets/assets/images/splash_logo.png": "c99891fb32e8e6f0d9af5f70aa469f9f",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/NOTICES": "dcf4b167632fa54b52b251d9e049cbfd",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "b93248a553f9e8bc17f1065929d5934b",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "8e81da542ac3a2ffd769c7fd6de72c49",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"flutter_bootstrap.js": "bda66be1a4ac78ed727a0fbf32e8f05b",
"icons/Icon-192.png": "3f91ed7bc652046fe8f49a60cb173d85",
"icons/Icon-512.png": "d2e0f3bb6c52ccf7156e7f85b48de22d",
"icons/Icon-maskable-192.png": "3f91ed7bc652046fe8f49a60cb173d85",
"icons/Icon-maskable-512.png": "d2e0f3bb6c52ccf7156e7f85b48de22d",
"index.html": "aefa6e35ed8204d2e66afb01ffe684f9",
"/": "aefa6e35ed8204d2e66afb01ffe684f9",
"main.dart.js": "e067153f3729a18906d302432c324026",
"manifest.json": "e6430a106bb70d31b438cb64b23d1d48",
"version.json": "ccba061864bc5bcf05c52d1f0ba2c3dd"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
