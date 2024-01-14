//
//  ContentView.swift
//  Pick.Mart.-HomeHeader
//
//  Created by 金山義成 on 2024/01/14.
//

import SwiftUI

struct ContentView: View {
    //headerを上下させる変数
    @State var offsetHeader: CGFloat = 0
    //headerを透明か否かにする変数
    @State var opacityHeader: Double = 1
    //どのくらいスクロールしたか
    @State var scrollOffset: CGFloat = 0
    //positionYの初期値
    @State var initialPositionY: CGFloat = 0
    //上にいきすぎないようにoffsetを止める
    @State var stopOffset: CGFloat = 0
    
    //ヘッダーの高さ
    var heightOfHeader: CGFloat = 40
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader{ reader in
                ZStack{
                    VStack(spacing:0){
                        //これがないとスクロールViewが上に貫通する
                        Rectangle()
                            .frame(height:1)
                            .foregroundStyle(.white)
                        ScrollView(showsIndicators: false){
                            //ロゴ分のスペースを上にあける
                            Spacer()
                                .frame(height:heightOfHeader)
                                .id(0)
                            //分かりやすいように青赤交互のRectangleを並べる
                            VStack(spacing:0){
                                ForEach(0..<20, id:\.self){ i in
                                    Rectangle()
                                        .frame(height:100)
                                        .foregroundColor(i % 2 == 0 ? .red : .blue)
                                }
                            }
                            .onAppear(){
                                //ヘッダー＋セーフエリアの合計
                                initialPositionY = geometry.frame(in: .global).origin.y
                            }
                            // スクロールのオフセットを取得する
                            .overlay(
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(key: ViewOffsetKey.self, value: geo.frame(in: .global).minY)
                                }
                            )
                            
                        }
                        // スクロールのオフセットを変数に反映する
                        .onPreferenceChange(ViewOffsetKey.self) { value in
                            //28行目のSpacer＋セーフエリア分の調整
                            scrollOffset = value - (heightOfHeader + initialPositionY)
                            
                            //スクロールした分とヘッダーのオフセットを同期
                            offsetHeader = scrollOffset - stopOffset
                            
                            //scrollOffsetが0に近づくほど緩やかにopacityも0に
                            opacityHeader = offsetHeader/heightOfHeader + 1
                            
                            //ヘッダーが上に隠れたら、ヘッダーのオフセットの固定と、固定した場所で、スクロール分と同期
                            if offsetHeader <= -heightOfHeader{
                                offsetHeader = -heightOfHeader
                                stopOffset = scrollOffset - -heightOfHeader
                            }
                            
                            //ヘッダーが表示されている時は、またはスクロールが一番上の時、もっと上にスクロールするときに、ヘッダーをそれについて行かせない
                            else if offsetHeader > 0 || scrollOffset >= 0{
                                offsetHeader = 0
                                stopOffset = scrollOffset
                            }
                            
                        }
                    }
                    
                    
                    //ヘッダー
                    VStack{
                        ZStack{
                            Rectangle()
                                .foregroundColor(.white)
                            HStack(spacing:10){
                                //ロゴ
                                Text("Pick.Mart.")
                                    .font(.custom("gillsans-semibold", size: 40))
                                    .foregroundColor(Color("primaryColor"))
                                    .onTapGesture {
                                        //一番上に戻る
                                        withAnimation(){
                                            reader.scrollTo(0)
                                        }
                                    }
                                
                                Spacer()
                                
                                //番号検索
                                Image(systemName: "1.magnifyingglass")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.black)
                                    .opacity(0.4)
                                
                                //買い物リスト
                                Image(systemName: "text.book.closed")
                                    .font(.title)
                                    .foregroundStyle(.black)
                                    .opacity(0.4)
                                
                            }.padding(.horizontal)
                                .opacity(opacityHeader)
                        }.frame(height:heightOfHeader)
                            .offset(y:offsetHeader)
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

// スクロールのオフセットを取得するためのキー
struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
