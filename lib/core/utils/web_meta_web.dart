// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void updatePropertyMeta({
  required String title,
  required String description,
  String? imageUrl,
  required String url,
}) {
  final head = html.document.head;
  if (head == null) return;

  final summary = description.trim().length <= 180
      ? description.trim()
      : '${description.trim().substring(0, 179)}…';
  final absoluteUrl = url.startsWith('http') ? url : Uri.base.toString();
  final absoluteImage = imageUrl == null || imageUrl.isEmpty
      ? null
      : (imageUrl.startsWith('http')
          ? imageUrl
          : Uri.base.resolve(imageUrl).toString());

  html.document.title = title;
  _setMeta(head, 'name', 'description', summary);
  _setMeta(head, 'property', 'og:type', 'website');
  _setMeta(head, 'property', 'og:title', title);
  _setMeta(head, 'property', 'og:description', summary);
  _setMeta(head, 'property', 'og:url', absoluteUrl);
  _setMeta(head, 'name', 'twitter:card', 'summary_large_image');
  _setMeta(head, 'name', 'twitter:title', title);
  _setMeta(head, 'name', 'twitter:description', summary);
  _setMeta(head, 'name', 'twitter:url', absoluteUrl);

  if (absoluteImage != null) {
    _setMeta(head, 'property', 'og:image', absoluteImage);
    _setMeta(head, 'name', 'twitter:image', absoluteImage);
  }

  var canonical = head.querySelector('link[rel="canonical"]');
  if (canonical == null) {
    canonical = html.LinkElement();
    head.append(canonical);
  }
  canonical.setAttribute('rel', 'canonical');
  canonical.setAttribute('href', absoluteUrl);
}

void _setMeta(
  html.Element head,
  String keyAttribute,
  String key,
  String content,
) {
  var meta = head.querySelector('meta[$keyAttribute="$key"]');
  if (meta == null) {
    meta = html.MetaElement();
    head.append(meta);
  }
  meta.setAttribute(keyAttribute, key);
  meta.setAttribute('content', content);
}
