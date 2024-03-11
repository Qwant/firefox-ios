// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI

struct QwantEmptyPrivateTabsView: View {
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Spacer()

                    Image("qwant_private")

                    Text(String.QwantOmnibar.PrivateTabsTitle)
                        .foregroundColor(.white)
                        .font(.system(size: 19, weight: .semibold))
                        .multilineTextAlignment(.center)

                    Text(String.QwantOmnibar.PrivateTabsDescription)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.leading)
                        .padding(20)

                    Spacer()
                }
                .padding(20)
                .frame(minHeight: geometry.size.height)
            }
            .frame(width: geometry.size.width)
        }
    }
}

struct QwantEmptyPrivateTabsView_Previews: PreviewProvider {
    static var previews: some View {
        QwantEmptyPrivateTabsView()
    }
}
